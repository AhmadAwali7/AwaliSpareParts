-- ============================================================
--  AWALI HOME SPARE PARTS — Supabase setup
--  Run this whole file once in your Supabase project:
--  Dashboard → SQL Editor → New query → paste → Run.
-- ============================================================

-- ---------- tables ----------
create table if not exists public.profiles (
  id         uuid primary key references auth.users on delete cascade,
  email      text,
  name       text default '',
  role       text default 'customer',   -- 'customer' or 'owner'
  created_at timestamptz default now()
);

create table if not exists public.app_settings (
  id   int primary key default 1,
  data jsonb not null default '{}'::jsonb
);

create table if not exists public.products (
  id          text primary key,
  name        text not null,
  category    text,
  brand       text default '',
  part_number text default '',
  description text default '',
  image       text default '',        -- data URL or web URL
  show_price  boolean default true,
  price       numeric,
  offer_price numeric,
  in_stock    boolean default true,
  visible     boolean default true,
  created_at  timestamptz default now()
);

create table if not exists public.carts (
  user_id    uuid primary key references auth.users on delete cascade,
  items      jsonb not null default '[]'::jsonb,
  updated_at timestamptz default now()
);

-- ---------- owner helper (SECURITY DEFINER avoids RLS recursion) ----------
create or replace function public.is_owner()
returns boolean
language sql
security definer
stable
as $$
  select exists (select 1 from public.profiles where id = auth.uid() and role = 'owner');
$$;
grant execute on function public.is_owner() to anon, authenticated;

-- ---------- create a profile automatically for every new user ----------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
as $$
begin
  insert into public.profiles (id, email, name, role)
  values (new.id, new.email, coalesce(new.raw_user_meta_data->>'name',''), 'customer')
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------- Row Level Security ----------
alter table public.profiles     enable row level security;
alter table public.app_settings enable row level security;
alter table public.products     enable row level security;
alter table public.carts        enable row level security;

-- profiles: you can read/update your own; the owner can read/delete any
drop policy if exists "profiles_read"   on public.profiles;
drop policy if exists "profiles_update" on public.profiles;
drop policy if exists "profiles_delete" on public.profiles;
create policy "profiles_read"   on public.profiles for select using (auth.uid() = id or public.is_owner());
create policy "profiles_update" on public.profiles for update using (auth.uid() = id) with check (auth.uid() = id);
create policy "profiles_delete" on public.profiles for delete using (public.is_owner());

-- products: everyone can read; only the owner can change
drop policy if exists "products_read"  on public.products;
drop policy if exists "products_write" on public.products;
create policy "products_read"  on public.products for select using (true);
create policy "products_write" on public.products for all using (public.is_owner()) with check (public.is_owner());

-- settings: everyone can read; only the owner can change
drop policy if exists "settings_read"  on public.app_settings;
drop policy if exists "settings_write" on public.app_settings;
create policy "settings_read"  on public.app_settings for select using (true);
create policy "settings_write" on public.app_settings for all using (public.is_owner()) with check (public.is_owner());

-- carts: each user owns their own cart row
drop policy if exists "carts_own" on public.carts;
create policy "carts_own" on public.carts for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- ============================================================
--  AFTER RUNNING THE ABOVE:
--  1) In the app, open the account page and SIGN UP with the email
--     you want to be the owner (e.g. owner@awalispareparts.com).
--  2) Come back here and run this line (edit the email) to make it the owner:
--
--        update public.profiles set role = 'owner' where email = 'owner@awalispareparts.com';
--
--  3) In Dashboard → Authentication → Providers → Email, turn OFF
--     "Confirm email" so sign-ups log in immediately (recommended for a shop).
-- ============================================================

-- ---------- OPTIONAL: load the 8 demo products ----------
-- Run this block only if you want the sample catalogue to start with.
insert into public.products (id,name,category,brand,part_number,description,show_price,price,offer_price,in_stock,visible) values
 ('p1','Washing Machine Drain Pump','washing-machine','Universal','WMP-2840','High-flow drain pump for most front-loading washing machines.',true,24,16.5,true,true),
 ('p2','Refrigerator Thermostat','refrigerator','CoolTech','RT-K59','Adjustable temperature control thermostat, wide compatibility.',true,14.5,null,true,true),
 ('p3','AC Fan Capacitor 35uF','air-conditioner','DuraStart','CAP-35F','Dual-run capacitor 35+5 uF, 440V. Restores cooling performance.',true,12,8.75,true,true),
 ('p4','Vacuum Cleaner HEPA Filter','vacuum-cleaner','PureAir','VF-H13','Washable HEPA-13 filter, fits most canister and upright vacuums.',true,9.5,null,true,true),
 ('p5','Oven Heating Element 2000W','oven','HeatPro','OHE-2K','Lower bake heating element, 2000W stainless steel.',false,null,null,true,true),
 ('p6','Washing Machine Door Seal','washing-machine','SealTight','DS-FL60','Rubber door boot gasket for front-load washers, leak-proof.',true,38,29,true,true),
 ('p7','Refrigerator Evaporator Fan Motor','refrigerator','CoolTech','EFM-12D','12V DC evaporator fan motor for no-frost refrigerators.',true,19.75,null,false,true),
 ('p8','AC Remote Control (Universal)','air-conditioner','DuraStart','RC-UNI1','Universal AC remote supporting 1000+ brands.',true,7.5,4.9,true,true)
on conflict (id) do nothing;
