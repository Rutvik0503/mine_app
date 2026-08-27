"use client";

import { useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { createSupabaseBrowserClient } from "@/lib/supabase/browserClient";

export function LoginForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const notAdmin = searchParams.get("error") === "not_admin";

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    setError(null);
    const supabase = createSupabaseBrowserClient();
    const { error: signInError } = await supabase.auth.signInWithPassword({ email, password });
    setLoading(false);
    if (signInError) {
      setError(signInError.message);
      return;
    }
    router.replace("/");
    router.refresh();
  }

  return (
    <form onSubmit={handleSubmit} className="panel p-8 w-full max-w-sm">
      <h1 className="text-xl font-bold mb-1">Admin Panel</h1>
      <p className="text-sm text-[#a0a7c0] mb-6">Virtual Mining Empire</p>

      {notAdmin && (
        <p className="text-sm text-[#ff5c6c] mb-4">
          That account signed in but isn&apos;t an admin. Ask a superadmin to add you to
          admin_users.
        </p>
      )}
      {error && <p className="text-sm text-[#ff5c6c] mb-4">{error}</p>}

      <label className="block text-sm mb-1">Email</label>
      <input
        className="input w-full mb-4"
        type="email"
        required
        value={email}
        onChange={(e) => setEmail(e.target.value)}
      />

      <label className="block text-sm mb-1">Password</label>
      <input
        className="input w-full mb-6"
        type="password"
        required
        value={password}
        onChange={(e) => setPassword(e.target.value)}
      />

      <button className="btn w-full justify-center" type="submit" disabled={loading}>
        {loading ? "Signing in..." : "Sign In"}
      </button>
    </form>
  );
}
