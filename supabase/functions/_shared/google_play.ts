// Google Play Developer API access for verifying and consuming in-app
// purchases. Authenticates as a service account whose JSON key is stored in
// the GOOGLE_PLAY_SERVICE_ACCOUNT secret; that account must be invited in
// Play Console (Users and permissions) with financial-data access.

const ANDROID_PACKAGE = "com.virtualminingempire.app";
const SCOPE = "https://www.googleapis.com/auth/androidpublisher";
const API = "https://androidpublisher.googleapis.com/androidpublisher/v3/applications";

interface ServiceAccount {
  client_email: string;
  private_key: string;
  token_uri?: string;
}

/** Fields of a purchases.products resource this app relies on. */
export interface PlayProductPurchase {
  purchaseState: number; // 0 purchased, 1 canceled, 2 pending
  consumptionState: number; // 0 not yet consumed, 1 consumed
  orderId?: string;
  obfuscatedExternalAccountId?: string;
  purchaseType?: number; // 0 test (license tester), 1 promo, 2 rewarded
}

let cachedToken: { value: string; expiresAt: number } | null = null;

function base64url(data: ArrayBuffer | Uint8Array | string): string {
  const bytes = typeof data === "string" ? new TextEncoder().encode(data) : new Uint8Array(data);
  let binary = "";
  for (const b of bytes) binary += String.fromCharCode(b);
  return btoa(binary).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

async function accessToken(): Promise<string> {
  if (cachedToken && cachedToken.expiresAt > Date.now() + 60_000) return cachedToken.value;

  const raw = Deno.env.get("GOOGLE_PLAY_SERVICE_ACCOUNT");
  if (!raw) throw new Error("Google Play billing is not configured on the server");
  const sa: ServiceAccount = JSON.parse(raw);
  const tokenUri = sa.token_uri ?? "https://oauth2.googleapis.com/token";

  const now = Math.floor(Date.now() / 1000);
  const header = base64url(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const claims = base64url(JSON.stringify({ iss: sa.client_email, scope: SCOPE, aud: tokenUri, iat: now, exp: now + 3600 }));

  const pem = sa.private_key.replace(/-----[^-]+-----/g, "").replace(/\s+/g, "");
  const der = Uint8Array.from(atob(pem), (c) => c.charCodeAt(0));
  const key = await crypto.subtle.importKey(
    "pkcs8",
    der,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(`${header}.${claims}`),
  );
  const assertion = `${header}.${claims}.${base64url(signature)}`;

  const res = await fetch(tokenUri, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({ grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer", assertion }),
  });
  const body = await res.json();
  if (!res.ok) throw new Error(`Google auth failed: ${body.error_description ?? body.error ?? res.status}`);

  cachedToken = { value: body.access_token, expiresAt: Date.now() + Number(body.expires_in ?? 3600) * 1000 };
  return cachedToken.value;
}

function productUrl(productId: string, token: string): string {
  return `${API}/${ANDROID_PACKAGE}/purchases/products/${encodeURIComponent(productId)}/tokens/${encodeURIComponent(token)}`;
}

export async function getProductPurchase(productId: string, token: string): Promise<PlayProductPurchase> {
  const res = await fetch(productUrl(productId, token), {
    headers: { Authorization: `Bearer ${await accessToken()}` },
  });
  const body = await res.json();
  if (!res.ok) throw new Error(`Google Play rejected the purchase: ${body.error?.message ?? res.status}`);
  return body as PlayProductPurchase;
}

/** Consumes a purchase so the same product can be bought again. */
export async function consumeProductPurchase(productId: string, token: string): Promise<void> {
  const res = await fetch(`${productUrl(productId, token)}:consume`, {
    method: "POST",
    headers: { Authorization: `Bearer ${await accessToken()}` },
  });
  if (!res.ok) {
    const body = await res.text();
    throw new Error(`Consume failed (${res.status}): ${body}`);
  }
}
