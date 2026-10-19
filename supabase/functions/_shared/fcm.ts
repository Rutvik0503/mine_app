// Firebase Cloud Messaging (HTTP v1) for server-sent pushes - things the
// phone can't schedule itself (a friend joined, "come back" after days
// away). Everything time-based for the player's own game (mining done,
// streak, daily bonus) is a local notification scheduled on the phone.
//
// Auth: service account JSON in the FIREBASE_SERVICE_ACCOUNT secret
// (Firebase console > Project settings > Service accounts > Generate new
// private key, project "virtual-mining-empire").

import { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

const SCOPE = "https://www.googleapis.com/auth/firebase.messaging";

export type Lang = "en" | "gu" | "hi";
export type LocalizedText = Record<Lang, string>;

export interface PushMessage {
  title: LocalizedText;
  body: LocalizedText;
  /** Also saved to the in-app notifications list (bell icon). */
  type?: string;
}

interface ServiceAccount {
  project_id: string;
  client_email: string;
  private_key: string;
  token_uri?: string;
}

let cached: { token: string; expiresAt: number; projectId: string } | null = null;

function b64url(data: ArrayBuffer | string): string {
  const bytes = typeof data === "string" ? new TextEncoder().encode(data) : new Uint8Array(data);
  let s = "";
  for (const b of bytes) s += String.fromCharCode(b);
  return btoa(s).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

async function auth(): Promise<{ token: string; projectId: string }> {
  if (cached && cached.expiresAt > Date.now() + 60_000) return cached;
  const raw = Deno.env.get("FIREBASE_SERVICE_ACCOUNT");
  if (!raw) throw new Error("FIREBASE_SERVICE_ACCOUNT is not set");
  const sa: ServiceAccount = JSON.parse(raw);
  const tokenUri = sa.token_uri ?? "https://oauth2.googleapis.com/token";
  const now = Math.floor(Date.now() / 1000);
  const unsigned = `${b64url(JSON.stringify({ alg: "RS256", typ: "JWT" }))}.${
    b64url(JSON.stringify({ iss: sa.client_email, scope: SCOPE, aud: tokenUri, iat: now, exp: now + 3600 }))
  }`;
  const der = Uint8Array.from(
    atob(sa.private_key.replace(/-----[^-]+-----/g, "").replace(/\s+/g, "")),
    (c) => c.charCodeAt(0),
  );
  const key = await crypto.subtle.importKey("pkcs8", der, { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" }, false, [
    "sign",
  ]);
  const sig = await crypto.subtle.sign("RSASSA-PKCS1-v1_5", key, new TextEncoder().encode(unsigned));
  const res = await fetch(tokenUri, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: `${unsigned}.${b64url(sig)}`,
    }),
  });
  const body = await res.json();
  if (!res.ok) throw new Error(`Firebase auth failed: ${body.error_description ?? body.error ?? res.status}`);
  cached = {
    token: body.access_token,
    expiresAt: Date.now() + Number(body.expires_in ?? 3600) * 1000,
    projectId: sa.project_id,
  };
  return cached;
}

/**
 * Sends [message] to every device of [userId], each in its own language,
 * and saves it to the in-app notifications list. Never throws - a push is
 * a nice-to-have, it must not break the action that triggered it. Tokens
 * FCM reports as gone are deleted.
 */
export async function sendPushToUser(admin: SupabaseClient, userId: string, message: PushMessage): Promise<void> {
  try {
    const { data: devices } = await admin.from("device_tokens").select("id, token, language").eq("user_id", userId);

    const firstLang = ((devices?.[0]?.language as Lang) ?? "en");
    await admin.from("notifications").insert({
      user_id: userId,
      title: message.title[firstLang] ?? message.title.en,
      body: message.body[firstLang] ?? message.body.en,
      type: message.type ?? "general",
    });

    if (!devices || devices.length === 0) return;
    const { token: accessToken, projectId } = await auth();

    for (const device of devices) {
      const lang = (device.language as Lang) ?? "en";
      const res = await fetch(`https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`, {
        method: "POST",
        headers: { Authorization: `Bearer ${accessToken}`, "Content-Type": "application/json" },
        body: JSON.stringify({
          message: {
            token: device.token,
            notification: { title: message.title[lang] ?? message.title.en, body: message.body[lang] ?? message.body.en },
            android: { priority: "high", notification: { channel_id: "mining_channel" } },
          },
        }),
      });
      if (!res.ok) {
        const err = await res.text();
        if (res.status === 404 || err.includes("UNREGISTERED") || err.includes("INVALID_ARGUMENT")) {
          await admin.from("device_tokens").delete().eq("id", device.id);
        } else {
          console.warn(`FCM send failed (${res.status}): ${err}`);
        }
      }
    }
  } catch (e) {
    console.warn("sendPushToUser failed:", e instanceof Error ? e.message : e);
  }
}
