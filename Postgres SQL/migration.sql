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

-- trigger tạo profile khi có user mới
create or replace function handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, role_id)
  values (
    new.id,
    new.raw_user_meta_data->>'full_name', -- lấy full_name nếu có trong metadata
    (select id from public.roles where name = 'viewer' limit 1) -- mặc định gán role viewer
  );
  return new;
end;
$$ language plpgsql security definer;

-- Gắn trigger vào bảng auth.users
drop trigger if exists trg_handle_new_user on auth.users;
create trigger trg_handle_new_user
after insert on auth.users
for each row execute function handle_new_user();


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
-- BẢNG REGIONS (KHU VỰC)
-- ======================================
create table public.regions (
    id uuid primary key,
    name text not null,             -- Tên khu vực (VD: "Huyện Cần Giờ", "Nông trại A")
    description text,               -- Mô tả thêm
    parent_id uuid references public.regions(id) on delete cascade, -- hỗ trợ phân cấp (tỉnh -> huyện -> xã -> farm)
    is_active boolean default true, -- trạng thái hoạt động

    created_at timestamptz default now(),
    updated_at timestamptz default now()
);
-- Trigger auto update recorded_at
create or replace function update_regions_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists update_regions_updated_at on public.regions;
create trigger update_regions_updated_at
before update on public.regions
for each row execute function update_regions_updated_at();

-- ======================================
-- BẢNG ENVIRONMENTAL DATA
-- ======================================
create table public.environmental_data (
    id uuid primary key,

    -- Liên kết khu vực
    region_id uuid not null references public.regions(id) on delete cascade,
    location text, -- chi tiết hơn: tọa độ GPS, mô tả địa điểm...

    -- Thông số môi trường
    temperature numeric,       -- nhiệt độ (°C)
    humidity numeric,          -- độ ẩm (%)
    ph numeric,                -- độ pH
    soil_moisture numeric,     -- độ ẩm đất
    light_intensity numeric,   -- cường độ ánh sáng
    co2_level numeric,         -- nồng độ CO2
    nitrogen numeric,          -- N
    phosphorus numeric,        -- P
    potassium numeric,         -- K
    weather_condition text,    -- thời tiết tổng quát
    notes text,

    -- Thời gian
    recorded_at timestamptz default now(),
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);
create index if not exists idx_environmental_data_region_id on public.environmental_data(region_id);


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

--- Regions
alter table public.regions enable row level security;

-- Viewer: chỉ xem các vùng đang active
create policy "Viewers can view active regions"
on public.regions
for select
using (
  is_viewer(auth.uid())
  and is_active = true
);

-- Editor: được xem tất cả
create policy "Editors can view all regions"
on public.regions
for select
using (is_editor(auth.uid()));

-- Editor: được insert
create policy "Editors can insert regions"
on public.regions
for insert
with check (is_editor(auth.uid()));

-- Editor: được update
create policy "Editors can update regions"
on public.regions
for update
using (is_editor(auth.uid()))
with check (is_editor(auth.uid()));

-- Admin: toàn quyền
create policy "Admins can manage all regions"
on public.regions
for all
using (is_admin(auth.uid()))
with check (is_admin(auth.uid()));


-- Environmental data
alter table public.environmental_data enable row level security;

-- Viewer/Editor/Admin: được SELECT
create policy "All roles can view environmental data"
on public.environmental_data
for select
using (
  is_viewer(auth.uid())
  or is_editor(auth.uid())
  or is_admin(auth.uid())
);

-- Editor: được INSERT
create policy "Editors can insert environmental data"
on public.environmental_data
for insert
with check (is_editor(auth.uid()));

-- Editor: được UPDATE
create policy "Editors can update environmental data"
on public.environmental_data
for update
using (is_editor(auth.uid()))
with check (is_editor(auth.uid()));

-- Admin: full quyền (SELECT, INSERT, UPDATE, DELETE…)
create policy "Admins can manage all environmental data"
on public.environmental_data
for all
using (is_admin(auth.uid()))
with check (is_admin(auth.uid()));

-- ======================================
-- VIEW: USERS WITH ROLES
-- ======================================
create or replace function get_users_with_roles()
returns table (
  id uuid,
  email text,
  full_name text,
  role_name text,
  user_created_at timestamptz,
  profile_created_at timestamptz,
  profile_updated_at timestamptz
)
language plpgsql
security definer
set search_path = public, auth
as $$
begin
  -- Chỉ admin mới được xem
  if not is_admin(auth.uid()) then
    raise exception 'Chỉ admin mới có quyền xem danh sách users';
  end if;

  return query
  select 
    u.id,
    u.email::text,
    p.full_name,
    r.name::text as role_name,
    u.created_at as user_created_at,
    p.created_at as profile_created_at,
    p.updated_at as profile_updated_at
  from auth.users u
  left join public.profiles p on u.id = p.id
  left join public.roles r on r.id = p.role_id;
end;
$$;

revoke execute on function get_users_with_roles() from public;
grant execute on function get_users_with_roles() to authenticated;
