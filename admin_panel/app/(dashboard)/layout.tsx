import Link from "next/link";
import { requireAdmin } from "@/lib/requireAdmin";
import { LogoutButton } from "./LogoutButton";

const NAV_ITEMS = [
  { href: "/", label: "Dashboard" },
  { href: "/users", label: "Users" },
  { href: "/mining-settings", label: "Mining Settings" },
  { href: "/machines", label: "Machines" },
  { href: "/farms", label: "Farm Types" },
  { href: "/missions", label: "Missions" },
  { href: "/referrals", label: "Referrals" },
];

export default async function DashboardLayout({ children }: { children: React.ReactNode }) {
  const admin = await requireAdmin();

  return (
    <div className="flex min-h-screen">
      <aside className="w-64 shrink-0 border-r border-[#2A3350] p-5 flex flex-col">
        <div className="mb-8">
          <div className="font-bold text-lg">Mining Empire</div>
          <div className="text-xs text-[#a0a7c0]">Admin Panel</div>
        </div>
        <nav className="flex-1 flex flex-col gap-1">
          {NAV_ITEMS.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className="px-3 py-2 rounded-lg text-sm hover:bg-[#1C2338] transition-colors"
            >
              {item.label}
            </Link>
          ))}
        </nav>
        <div className="pt-4 border-t border-[#2A3350] text-xs text-[#a0a7c0]">
          <div className="mb-2">{admin.email}</div>
          <div className="mb-3 uppercase tracking-wide">{admin.role}</div>
          <LogoutButton />
        </div>
      </aside>
      <main className="flex-1 p-8 max-w-6xl">{children}</main>
    </div>
  );
}
