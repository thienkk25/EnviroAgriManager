-- ======================================
-- EXTENSIONS
-- ======================================
create extension if not exists "uuid-ossp";

-- ======================================
-- ENUM TYPE: PRODUCT STATUS
-- ======================================
drop type if exists product_status cascade;
create type product_status as enum ('active', 'inactive', 'discontinued');

-- ======================================
-- BẢNG ROLES
-- ======================================
create table if not exists public.roles (
  id serial primary key,
  name text unique not null,
  description text,
  created_at timestamptz default now()
);

-- ======================================
-- BẢNG PROFILES
-- ======================================
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  role_id int references public.roles(id),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index if not exists idx_profiles_role_id on public.profiles(role_id);

-- Trigger updated_at cho profiles
create or replace function update_profiles_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_update_profiles_updated_at on public.profiles;
create trigger trg_update_profiles_updated_at
before update on public.profiles
for each row execute function update_profiles_updated_at();

-- ======================================
-- HELPER FUNCTIONS: ROLE CHECK
-- ======================================
create or replace function public.is_admin(uid uuid)
returns boolean as $$
  select exists (
    select 1 from public.profiles p
    join public.roles r on r.id = p.role_id
    where p.id = uid and r.name = 'admin'
  );
$$ language sql stable;

create or replace function public.is_editor(uid uuid)
returns boolean as $$
  select exists (
    select 1 from public.profiles p
    join public.roles r on r.id = p.role_id
    where p.id = uid and r.name = 'editor'
  );
$$ language sql stable;

create or replace function public.is_viewer(uid uuid)
returns boolean as $$
  select exists (
    select 1 from public.profiles p
    join public.roles r on r.id = p.role_id
    where p.id = uid and r.name = 'viewer'
  );
$$ language sql stable;

-- ======================================
-- BẢNG CATEGORIES
-- ======================================
create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
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
create or replace function update_categories_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists update_categories_updated_at on public.categories;
create trigger update_categories_updated_at
before update on public.categories
for each row execute function update_categories_updated_at();

-- ======================================
-- BẢNG PRODUCTS
-- ======================================
create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  category_id uuid references public.categories(id) on delete set null,
  price numeric default 0,
  quantity integer default 0,
  unit text default '',
  image_url text default '',
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  status product_status default 'active',
  environmental_data jsonb default '{}'::jsonb
);

-- Trigger updated_at
create or replace function update_products_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists update_products_updated_at on public.products;
create trigger update_products_updated_at
before update on public.products
for each row execute function update_products_updated_at();

-- ======================================
-- CHẶN INSERT/UPDATE PRODUCT NẾU CATEGORY INACTIVE
-- ======================================
-- Function kiểm tra category phải active khi update/insert product
create or replace function check_category_active_for_product()
returns trigger as $$
declare
  v_category_active boolean;
begin
  -- Kiểm tra category phải active
  select is_active into v_category_active
  from public.categories
  where id = new.category_id;
  
  if v_category_active is null then
    raise exception 'Không thể xóa danh mục đang có sản phẩm';
  end if;
  
  if v_category_active = false then
    raise exception 'Không thể thêm/cập nhật sản phẩm vào category đã bị inactive';
  end if;
  
  return new;
end;
$$ language plpgsql;

-- Trigger áp dụng cho cả INSERT và UPDATE
drop trigger if exists trg_check_category_active on public.products;
create trigger trg_check_category_active
before insert or update on public.products
for each row
execute function check_category_active_for_product();

-- ======================================
-- BẢNG ENVIRONMENTAL DATA
-- ======================================
create table if not exists public.environmental_data (
  id uuid primary key default gen_random_uuid(),
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
create or replace function update_environmental_data_updated_at()
returns trigger as $$
begin
  new.recorded_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists update_environmental_data_updated_at on public.environmental_data;
create trigger update_environmental_data_updated_at
before update on public.environmental_data
for each row execute function update_environmental_data_updated_at();


-- ======================================
-- RLS POLICIES
-- ======================================

-- Profiles
alter table public.profiles enable row level security;

create policy "Users can read own profile"
on public.profiles for select
using (auth.uid() = id);

create policy "Users can update own profile"
on public.profiles for update
using (auth.uid() = id);

create policy "Admins can view all profiles"
on public.profiles for select
using (is_admin(auth.uid()));

create policy "Admins can update all profiles"
on public.profiles for update
using (is_admin(auth.uid()));

-- Categories
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

-- Products
alter table public.products enable row level security;

create policy "Viewers can view active products"
on public.products for select
using (
  status = 'active'
  and exists (
    select 1 from public.categories c
    where c.id = products.category_id
      and c.is_active = true
  )
);

create policy "Editors can view all products"
on public.products for select
using (is_editor(auth.uid()));

create policy "Editors can insert products"
on public.products for insert
with check (
  is_editor(auth.uid())
  and exists (
    select 1 from public.categories c
    where c.id = products.category_id
      and c.is_active = true
  )
);

create policy "Editors can update products"
on public.products for update
using (is_editor(auth.uid()));

create policy "Admins can manage all products"
on public.products for all
using (is_admin(auth.uid()));

-- Environmental data
alter table public.environmental_data enable row level security;

create policy "Viewers can view environmental data"
on public.environmental_data for select
using (
  exists (
    select 1
    from public.products p
    join public.categories c on c.id = p.category_id
    where p.id = environmental_data.product_id
      and p.status = 'active'
      and c.is_active = true
  )
);

create policy "Editors can insert environmental data"
on public.environmental_data for insert
with check (
  is_editor(auth.uid())
  and exists (
    select 1
    from public.products p
    join public.categories c on c.id = p.category_id
    where p.id = environmental_data.product_id
      and p.status = 'active'
      and c.is_active = true
  )
);

create policy "Editors can update environmental data"
on public.environmental_data for update
using (
  is_editor(auth.uid())
  and exists (
    select 1
    from public.products p
    join public.categories c on c.id = p.category_id
    where p.id = environmental_data.product_id
      and p.status = 'active'
      and c.is_active = true
  )
);

create policy "Admins can manage all environmental data"
on public.environmental_data for all
using (is_admin(auth.uid()));
