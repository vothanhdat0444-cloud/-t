-- Chạy toàn bộ nội dung này trong Supabase > SQL Editor.
create table if not exists public.meci_private_state (
  id integer primary key,
  payload jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  updated_by uuid
);
create table if not exists public.meci_public_state (
  id integer primary key,
  payload jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
alter table public.meci_private_state enable row level security;
alter table public.meci_public_state enable row level security;

drop policy if exists "private read authenticated" on public.meci_private_state;
drop policy if exists "private insert authenticated" on public.meci_private_state;
drop policy if exists "private update authenticated" on public.meci_private_state;
drop policy if exists "public read everyone" on public.meci_public_state;
drop policy if exists "public insert authenticated" on public.meci_public_state;
drop policy if exists "public update authenticated" on public.meci_public_state;

create policy "private read authenticated" on public.meci_private_state for select to authenticated using (true);
create policy "private insert authenticated" on public.meci_private_state for insert to authenticated with check (true);
create policy "private update authenticated" on public.meci_private_state for update to authenticated using (true) with check (true);
create policy "public read everyone" on public.meci_public_state for select to anon, authenticated using (true);
create policy "public insert authenticated" on public.meci_public_state for insert to authenticated with check (true);
create policy "public update authenticated" on public.meci_public_state for update to authenticated using (true) with check (true);
