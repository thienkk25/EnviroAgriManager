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
  parent_id uuid references public.categories(id) on delete cascade,
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
-- Function kiểm tra category có product phụ thuộc không
-- ======================================
create or replace function check_category_has_products()
returns trigger as $$
declare
  v_product_count integer;
begin
  select count(*) into v_product_count
  from public.products
  where category_id = old.id;
  
  if v_product_count > 0 then
    raise exception 'Không thể xóa danh mục đang có sản phẩm';
  end if;
  
  return old;
end;
$$ language plpgsql;

CREATE TRIGGER trg_check_category_has_products
BEFORE DELETE ON public.categories
FOR EACH ROW
EXECUTE FUNCTION check_category_has_products();


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
-- Function kiểm tra Region có Environment data phụ thuộc không
-- ======================================
create or replace function check_region_has_environment_data()
returns trigger as $$
declare
  v_environment_data_count integer;
begin
  select count(*) into v_environment_data_count
  from public.environmental_data
  where region_id = old.id;
  
  if v_environment_data_count > 0 then
    raise exception 'Không thể xóa vị trí đang có dữ liệu môi trường phụ thuộc';
  end if;
  
  return old;
end;
$$ language plpgsql;

CREATE TRIGGER trg_check_region_has_environment_data
BEFORE DELETE ON public.regions
FOR EACH ROW
EXECUTE FUNCTION check_region_has_environment_data();

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

--- Roles
alter table public.roles enable row level security;

create policy "Allow authenticated to read roles"
on roles for select
to authenticated
using (true);

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


-- ======================================
-- FUNCTION: LẤY DỮ LIỆU MÔI TRƯỜNG THEO KHU VỰC VÀ CÁC KHU VỰC CON AND THEO KHOẢNG THỜI GIAN
-- ======================================

CREATE OR REPLACE FUNCTION get_environmental_data_filtered(
    v_region_id uuid,
    v_start_date timestamp with time zone,
    v_end_date timestamp with time zone
)
RETURNS TABLE (
    id uuid,
    region_id uuid,
    location text,
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
    notes text,
    recorded_at timestamp with time zone
) AS $$
BEGIN
    RETURN QUERY
    WITH RECURSIVE region_hierarchy AS (
        -- lấy region cha và tất cả con
        SELECT r.id AS cte_id
        FROM regions r
        WHERE r.id = v_region_id

        UNION ALL

        SELECT r.id AS cte_id
        FROM regions r
        INNER JOIN region_hierarchy rh ON r.parent_id = rh.cte_id
    )
    SELECT 
        ed.id,
        ed.region_id,
        ed.location,
        ed.temperature,
        ed.humidity,
        ed.ph,
        ed.soil_moisture,
        ed.light_intensity,
        ed.co2_level,
        ed.nitrogen,
        ed.phosphorus,
        ed.potassium,
        ed.weather_condition,
        ed.notes,
        ed.recorded_at
    FROM environmental_data ed
    WHERE ed.region_id IN (SELECT cte_id FROM region_hierarchy)
      AND ed.recorded_at >= v_start_date
      AND ed.recorded_at <= v_end_date
    ORDER BY ed.recorded_at DESC;
END;
$$ LANGUAGE plpgsql;

-- Bật Row-Level Security (RLS) cho bảng storage.objects
alter table storage.objects enable row level security;

create policy "Allow anyone to view images"
on storage.objects
for select
using (bucket_id = 'product-images');

create policy "Allow admin and editor to manage product images"
on storage.objects
for all
to authenticated
using (
  bucket_id = 'product-images'
  and exists (
    select 1
    from public.profiles p
    join public.roles r on r.id = p.role_id
    where p.id = auth.uid()
      and r.name in ('admin', 'editor')
  )
)
with check (
  bucket_id = 'product-images'
  and exists (
    select 1
    from public.profiles p
    join public.roles r on r.id = p.role_id
    where p.id = auth.uid()
      and r.name in ('admin', 'editor')
  )
);

-- ===========================================
--  BẢNG PRODUCT_REVIEWS
-- ===========================================
create table if not exists public.product_reviews (
  id uuid primary key default gen_random_uuid(),
  product_id uuid references public.products(id) on delete cascade,
  edited_by uuid references public.profiles(id) on delete cascade,
  reviewed_by uuid references auth.users(id),
  status text check (status in ('pending', 'approved', 'rejected')) default 'pending',
  changes jsonb, -- chứa dữ liệu thay đổi (ví dụ: {"name": "New name", "price": 20})
  note text, -- ghi chú của editor hoặc admin (tùy chọn)
  created_at timestamptz default now(),
  reviewed_at timestamptz
);

-- ===========================================
--  FUNCTION RPC: ADMIN DUYỆT HOẶC TỪ CHỐI REVIEW
-- ===========================================
create or replace function public.approve_or_reject_review(
  p_review_id uuid,
  p_action text  -- 'approve' hoặc 'reject'
)
returns void as $$
declare
  v_product_id uuid;
  v_changes jsonb;
  v_sql text;
  v_key text;
  v_value jsonb;
  v_pairs text := '';
  v_final_value text;
  v_is_new_product boolean := false;
  v_columns text := '';
  v_values text := '';
begin
  -- Kiểm tra quyền
  if not is_admin(auth.uid()) then
    raise exception 'Access denied: only admin can approve or reject reviews';
  end if;

  -- Lấy thông tin review
  select product_id, changes
  into v_product_id, v_changes
  from public.product_reviews
  where id = p_review_id;

  if not found then
    raise exception 'Review not found: %', p_review_id;
  end if;

  -- Xác định INSERT hay UPDATE
  if v_product_id is null then
    -- Tạo UUID mới cho sản phẩm
    v_product_id := gen_random_uuid();
    v_is_new_product := true;
    
    raise notice 'Creating new product with ID: %', v_product_id;
  else
    -- Kiểm tra sản phẩm cũ có tồn tại không
    if not exists (select 1 from public.products where id = v_product_id) then
      raise exception 'Invalid product_id: % (not found in products)', v_product_id;
    end if;
    
    raise notice 'Updating existing product: %', v_product_id;
  end if;

  if p_action = 'approve' then
    if v_is_new_product then
      -- INSERT sản phẩm mới
      for v_key, v_value in
        select key, value from jsonb_each(v_changes)
      loop
        -- Bỏ qua id cũ nếu có trong changes
        if v_key in ('id', 'created_at', 'updated_at') then
          continue;
        end if;

        -- Xử lý giá trị
        case jsonb_typeof(v_value)
          when 'string' then
            v_final_value := v_value #>> '{}';
          when 'number' then
            v_final_value := v_value::text;
          when 'boolean' then
            v_final_value := v_value::text;
          when 'null' then
            v_final_value := 'NULL';
          else
            v_final_value := v_value::text;
        end case;

        -- Thêm vào danh sách columns và values
        if v_columns <> '' then
          v_columns := v_columns || ', ';
          v_values := v_values || ', ';
        end if;

        v_columns := v_columns || format('%I', v_key);
        
        if v_final_value = 'NULL' then
          v_values := v_values || 'NULL';
        else
          v_values := v_values || format('%L', v_final_value);
        end if;
      end loop;

      if v_columns = '' then
        raise exception 'No data to insert for new product';
      end if;

      -- Execute INSERT
      v_sql := format(
        'INSERT INTO public.products (id, %s, created_at, updated_at) VALUES (%L, %s, now(), now())',
        v_columns,
        v_product_id,
        v_values
      );
      
      raise notice 'Executing INSERT: %', v_sql;
      execute v_sql;

    else
      -- UPDATE sản phẩm cũ
      for v_key, v_value in
        select key, value from jsonb_each(v_changes)
      loop
        -- Bỏ qua các trường metadata
        if v_key in ('id', 'created_at', 'updated_at') then
          continue;
        end if;

        if v_pairs <> '' then
          v_pairs := v_pairs || ', ';
        end if;

        -- Xử lý giá trị
        case jsonb_typeof(v_value)
          when 'string' then
            v_final_value := v_value #>> '{}';
          when 'number' then
            v_final_value := v_value::text;
          when 'boolean' then
            v_final_value := v_value::text;
          when 'null' then
            v_final_value := 'NULL';
          else
            v_final_value := v_value::text;
        end case;

        -- Format với giá trị đã xử lý
        if v_final_value = 'NULL' then
          v_pairs := v_pairs || format('%I = NULL', v_key);
        else
          v_pairs := v_pairs || format('%I = %L', v_key, v_final_value);
        end if;
      end loop;

      if v_pairs = '' then
        raise notice 'No changes to apply for product %', v_product_id;
      else
        -- Execute UPDATE
        v_sql := format('UPDATE public.products SET %s, updated_at = now() WHERE id = $1', v_pairs);
        raise notice 'Executing UPDATE: %', v_sql;
        execute v_sql using v_product_id;
      end if;
    end if;

    -- Cập nhật trạng thái review và lưu product_id
    update public.product_reviews
    set
      product_id = v_product_id,  -- Lưu lại product_id mới tạo
      status = 'approved',
      reviewed_by = auth.uid(),
      reviewed_at = now()
    where id = p_review_id;

  elsif p_action = 'reject' then
    update public.product_reviews
    set
      status = 'rejected',
      reviewed_by = auth.uid(),
      reviewed_at = now()
    where id = p_review_id;

  else
    raise exception 'Invalid action: %, must be approve or reject', p_action;
  end if;
end;
$$ language plpgsql security definer;

-- ===========================================
--  TRIGGER: TỰ GHI NGƯỜI DUYỆT & THỜI GIAN
-- ===========================================
create or replace function public.auto_fill_review_meta()
returns trigger as $$
begin
  if new.status in ('approved', 'rejected')
     and old.status <> new.status then
    new.reviewed_at := now();
    if new.reviewed_by is null then
      new.reviewed_by := auth.uid();
    end if;
  end if;
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists fill_review_meta on public.product_reviews;
create trigger fill_review_meta
before update on public.product_reviews
for each row
execute function public.auto_fill_review_meta();

-- ===========================================
--  RLS (ROW LEVEL SECURITY)
-- ===========================================
alter table public.product_reviews enable row level security;

-- Xem: admin xem tất cả, editor xem review của mình
create policy "View reviews"
on public.product_reviews for select
using (
  is_admin(auth.uid())
  or edited_by = auth.uid()
);

-- Thêm review mới (editor)
create policy "Insert review"
on public.product_reviews for insert
with check (is_editor(auth.uid()));

-- Cập nhật review pending của chính mình (editor)
create policy "Edit pending review"
on public.product_reviews for update
using (edited_by = auth.uid() and status = 'pending');

-- Xóa review pending của chính mình (editor)
create policy "Delete pending review"
on public.product_reviews for delete
using (edited_by = auth.uid() and status = 'pending');

-- Chỉ admin mới được update (duyệt hoặc từ chối)
create policy "Admin update reviews"
on public.product_reviews for update
using (is_admin(auth.uid()));


-- ======================================
-- TẠO BẢNG LƯU LOG
-- ======================================
create table if not exists public.audit_logs (
    id bigserial primary key,
    table_name text not null,             -- bảng thao tác
    action text not null,                 -- INSERT / UPDATE / DELETE
    record_id text,                       -- id hoặc khóa chính (nếu có)
    old_data jsonb,                       -- dữ liệu cũ
    new_data jsonb,                       -- dữ liệu mới
    performed_by uuid,                    -- người thực hiện (auth.uid() hoặc app.user_id)
    performed_at timestamptz default now()
);

-- ======================================
-- FUNCTION GHI LOG DÙNG CHUNG
-- ======================================
create or replace function public.log_changes()
returns trigger
language plpgsql
security definer
as $$
declare
    user_id uuid;
    pk_value text;
begin
    -- Ưu tiên lấy user từ context backend (nếu có set local app.user_id)
    begin
        user_id := current_setting('app.user_id', true)::uuid;
    exception when others then
        user_id := null;
    end;

    -- Nếu chưa có thì lấy auth.uid() (khi thao tác từ client Supabase)
    if user_id is null then
        begin
            user_id := auth.uid();
        exception when others then
            user_id := null;
        end;
    end if;

    -- Lấy khóa chính (nếu có cột id)
    if TG_OP = 'INSERT' then
        if to_jsonb(NEW) ? 'id' then pk_value := NEW.id::text; end if;

        insert into public.audit_logs(table_name, action, record_id, new_data, performed_by)
        values (TG_TABLE_NAME, 'INSERT', pk_value, to_jsonb(NEW), user_id);
        return NEW;

    elsif TG_OP = 'UPDATE' then
        if to_jsonb(NEW) ? 'id' then pk_value := NEW.id::text; end if;

        insert into public.audit_logs(table_name, action, record_id, old_data, new_data, performed_by)
        values (TG_TABLE_NAME, 'UPDATE', pk_value, to_jsonb(OLD), to_jsonb(NEW), user_id);
        return NEW;

    elsif TG_OP = 'DELETE' then
        if to_jsonb(OLD) ? 'id' then pk_value := OLD.id::text; end if;

        insert into public.audit_logs(table_name, action, record_id, old_data, performed_by)
        values (TG_TABLE_NAME, 'DELETE', pk_value, to_jsonb(OLD), user_id);
        return OLD;
    end if;

    return null;
end;
$$;


-- ======================================
-- SCRIPT GẮN TRIGGER TỰ ĐỘNG CHO TẤT CẢ BẢNG
-- ======================================
do $$
declare
    tbl record;
    trigger_name text;
begin
    for tbl in
        select tablename
        from pg_tables
        where schemaname = 'public'
          and tablename not in ('audit_logs')
    loop
        trigger_name := tbl.tablename || '_audit_trigger';

        execute format('drop trigger if exists %I on public.%I;', trigger_name, tbl.tablename);

        execute format($sql$
            create trigger %I
            after insert or update or delete
            on public.%I
            for each row
            execute function public.log_changes();
        $sql$, trigger_name, tbl.tablename);
    end loop;
end$$;


-- ======================================
-- POLICY CHỈ CHO ADMIN XEM LOG
-- ======================================
alter table public.audit_logs enable row level security;

drop policy if exists "admin can view audit logs" on public.audit_logs;
create policy "admin can view audit logs"
on public.audit_logs
for select
using (is_admin(auth.uid()));


