-- ===============================
-- BẢNG ROLES
-- ===============================
create table if not exists public.roles (
  id serial primary key,
  name text unique not null,
  description text,
  created_at timestamptz default now()
);

-- ===============================
-- BẢNG PROFILES
-- ===============================
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  role_id int references public.roles(id),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Index tối ưu join
create index if not exists idx_profiles_role_id on public.profiles(role_id);

-- Insert role mặc định
insert into public.roles (name, description)
values 
  ('admin', 'Quản trị toàn hệ thống'),
  ('editor', 'Người chỉnh sửa và quản lý dữ liệu'),
  ('viewer', 'Người chỉ xem dữ liệu')
on conflict (name) do nothing;

-- Trigger cập nhật updated_at cho profiles
create or replace function update_profiles_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_update_profiles_updated_at on profiles;
create trigger trg_update_profiles_updated_at
before update on profiles
for each row execute function update_profiles_updated_at();

-- Tự động tạo profile khi user mới đăng ký
create or replace function handle_new_user()
returns trigger as $$
declare
  v_role_id int;
begin
  select id into v_role_id from public.roles where name = 'viewer' limit 1;

  insert into public.profiles (id, full_name, role_id)
  values (new.id, new.raw_user_meta_data->>'full_name', v_role_id)
  on conflict (id) do nothing;

  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function handle_new_user();

-- ===============================
-- HELPER FUNCTIONS KIỂM TRA ROLE
-- ===============================
create or replace function is_admin(uid uuid)
returns boolean as $$
begin
  return exists (
    select 1 from public.profiles p
    join public.roles r on r.id = p.role_id
    where p.id = uid and r.name = 'admin'
  );
end;
$$ language plpgsql stable;

create or replace function is_editor(uid uuid)
returns boolean as $$
begin
  return exists (
    select 1 from public.profiles p
    join public.roles r on r.id = p.role_id
    where p.id = uid and r.name = 'editor'
  );
end;
$$ language plpgsql stable;

create or replace function is_viewer(uid uuid)
returns boolean as $$
begin
  return exists (
    select 1 from public.profiles p
    join public.roles r on r.id = p.role_id
    where p.id = uid and r.name = 'viewer'
  );
end;
$$ language plpgsql stable;

-- ===============================
-- RLS POLICIES CHO PROFILES
-- ===============================
alter table profiles enable row level security;

do $$
begin
  if not exists (select 1 from pg_policies where policyname = 'Users can read own profile') then
    create policy "Users can read own profile"
    on profiles for select
    using (auth.uid() = id);
  end if;

  if not exists (select 1 from pg_policies where policyname = 'Users can insert own profile') then
    create policy "Users can insert own profile"
    on profiles for insert
    with check (auth.uid() = id);
  end if;

  if not exists (select 1 from pg_policies where policyname = 'Users can update own profile') then
    create policy "Users can update own profile"
    on profiles for update
    using (auth.uid() = id);
  end if;

  if not exists (select 1 from pg_policies where policyname = 'Admins can view all profiles') then
    create policy "Admins can view all profiles"
    on profiles for select
    using (is_admin(auth.uid()));
  end if;

  if not exists (select 1 from pg_policies where policyname = 'Admins can update all profiles') then
    create policy "Admins can update all profiles"
    on profiles for update
    using (is_admin(auth.uid()));
  end if;
end$$;

-- ===============================
-- VIEW USERS + PROFILES
-- ===============================
create or replace view public.users_with_profiles as
select 
  u.id,
  u.email,
  p.full_name,
  r.name as role_name,
  u.created_at as user_created_at,
  p.created_at as profile_created_at,
  p.updated_at as profile_updated_at
from auth.users u
left join public.profiles p on u.id = p.id
left join public.roles r on r.id = p.role_id;

grant select on public.users_with_profiles to authenticated;
grant select on public.users_with_profiles to anon;


-- ===============================
-- BẢNG CATEGORIES
-- ===============================
create table if not exists public.categories (
  id uuid primary key,
  name text not null,
  description text,
  icon text default '🌱',
  color text default '#4CAF50',
  parent_id uuid references public.categories(id) on delete set null,
  sub_categories text[] default '{}',
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  is_active boolean default true
);

-- Trigger updated_at
create or replace function public.update_categories_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists update_categories_updated_at on public.categories;
create trigger update_categories_updated_at
before update on public.categories
for each row execute function public.update_categories_updated_at();

-- RLS cho categories
alter table public.categories enable row level security;

create policy "Viewers can view active categories"
on public.categories for select
using (is_active = true);

create policy "Editors can view all categories"
on public.categories for select
using (is_editor(auth.uid()));

create policy "Editors can insert categories"
on public.categories for insert
with check (is_editor(auth.uid()));

create policy "Editors can update categories"
on public.categories for update
using (is_editor(auth.uid()));

create policy "Admins can manage all categories"
on public.categories for all
using (is_admin(auth.uid()));


-- ===============================
-- BẢNG PRODUCTS
-- ===============================
create table if not exists public.products (
  id uuid primary key,
  name text not null,
  description text,
  category_id uuid references public.categories(id) on delete set null,
  price numeric default 0,
  quantity integer default 0,
  unit text default '',
  image_url text default '',
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  status text default 'active',
  environmental_data jsonb default '{}'::jsonb
);

-- Trigger updated_at
create or replace function public.update_products_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists update_products_updated_at on public.products;
create trigger update_products_updated_at
before update on public.products
for each row execute function public.update_products_updated_at();

-- RLS cho products
alter table public.products enable row level security;

create policy "Viewers can view active products"
on public.products for select
using (status = 'active');

create policy "Editors can view all products"
on public.products for select
using (is_editor(auth.uid()));

create policy "Editors can insert products"
on public.products for insert
with check (is_editor(auth.uid()));

create policy "Editors can update products"
on public.products for update
using (is_editor(auth.uid()));

create policy "Admins can manage all products"
on public.products for all
using (is_admin(auth.uid()));

-- View products kèm categories
create or replace view public.products_with_categories as
select 
  pr.id as product_id,
  pr.name as product_name,
  pr.description,
  pr.price,
  pr.quantity,
  pr.unit,
  pr.image_url,
  pr.status,
  pr.created_at,
  pr.updated_at,
  pr.environmental_data,
  c.id as category_id,
  c.name as category_name
from public.products pr
left join public.categories c on pr.category_id = c.id;

grant select on public.products_with_categories to authenticated;
grant select on public.products_with_categories to anon;


-- ===============================
-- BẢNG ENVIRONMENTAL DATA
-- ===============================
create table if not exists public.environmental_data (
  id uuid primary key,
  product_id uuid references public.products(id) on delete cascade,
  temperature numeric,
  humidity numeric,
  ph numeric,
  soil_moisture numeric,
  light_intensity numeric,
  co2_level numeric,
  nitrogen numeric,
  phosphorus numeric,
  potassium numeric,
  weather_condition text,
  location text,
  recorded_at timestamptz default now(),
  notes text
);

-- Trigger auto update recorded_at
create or replace function public.update_environmental_data_updated_at()
returns trigger as $$
begin
  new.recorded_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists update_environmental_data_updated_at on public.environmental_data;
create trigger update_environmental_data_updated_at
before update on public.environmental_data
for each row execute function public.update_environmental_data_updated_at();

-- RLS cho environmental_data
alter table public.environmental_data enable row level security;

create policy "Viewers can view environmental data"
on public.environmental_data for select
using (true);

create policy "Editors can insert environmental data"
on public.environmental_data for insert
with check (is_editor(auth.uid()));

create policy "Editors can update environmental data"
on public.environmental_data for update
using (is_editor(auth.uid()));

create policy "Admins can manage all environmental data"
on public.environmental_data for all
using (is_admin(auth.uid()));

-- View environmental_data kèm products
create or replace view public.environmental_data_with_products as
select 
  e.id as env_id,
  e.temperature,
  e.humidity,
  e.ph,
  e.soil_moisture,
  e.light_intensity,
  e.co2_level,
  e.nitrogen,
  e.phosphorus,
  e.potassium,
  e.weather_condition,
  e.location,
  e.recorded_at,
  e.notes,
  p.id as product_id,
  p.name as product_name
from public.environmental_data e
join public.products p on e.product_id = p.id;

grant select on public.environmental_data_with_products to authenticated;
