-- Machine detail screen gets a short description alongside its stats,
-- matching the reference app's richer "machine info" content.
alter table public.machines add column if not exists description text;

update public.machines set description =
  'A reliable entry-level rig. Efficient, low power draw, and a great way to start growing your hashrate.'
  where name = 'Miner X1';
update public.machines set description =
  'A balanced upgrade over the X1 with meaningfully higher hashrate for a similar footprint.'
  where name = 'Miner X5';
update public.machines set description =
  'An advanced rig built for serious miners - higher efficiency and a big jump in mining power.'
  where name = 'Miner Pro 9';
update public.machines set description =
  'The top-tier rig in your farm. Maximum hashrate and efficiency for players who want to push hard.'
  where name = 'Quantum Rig';
