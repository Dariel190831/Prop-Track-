-- PropTrack — schema, RLS y datos demo
-- Ejecutado directamente contra Supabase (Postgres). Ver README.md para cómo re-ejecutarlo.

-- =========================================================
-- TABLAS
-- =========================================================

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nombre text not null default '',
  plan text not null default 'mensual' check (plan in ('mensual','anual','equipo')),
  meta_mensual numeric not null default 120000,
  created_at timestamptz not null default now()
);

create table if not exists public.properties (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  titulo text not null,
  zona text,
  tipo text not null check (tipo in ('Casa','Apartamento','Terreno','Local')),
  precio numeric not null,
  estado text not null default 'Disponible' check (estado in ('Disponible','Negociando','Vendida')),
  habitaciones int,
  area numeric,
  area_unidad text check (area_unidad in ('m2','v2')),
  lat double precision,
  lng double precision,
  created_at timestamptz not null default now()
);

create table if not exists public.clients (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  nombre text not null,
  busca text,
  presupuesto numeric,
  etapa text not null default 'Contacto' check (etapa in ('Contacto','Visita','Negociando','Cerrado')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.deals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  property_id uuid references public.properties(id) on delete set null,
  client_id uuid references public.clients(id) on delete set null,
  cliente_nombre text not null,
  valor numeric not null,
  comision numeric not null,
  fecha_cierre date not null default current_date,
  created_at timestamptz not null default now()
);

create table if not exists public.activities (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  texto text not null,
  tipo text not null default 'info' check (tipo in ('info','success','warning')),
  created_at timestamptz not null default now()
);

create table if not exists public.matches (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  client_id uuid not null references public.clients(id) on delete cascade,
  property_id uuid not null references public.properties(id) on delete cascade,
  score int not null check (score between 0 and 100),
  created_at timestamptz not null default now()
);

-- =========================================================
-- RLS: cada usuario solo ve/edita su propia cartera
-- =========================================================

alter table public.profiles enable row level security;
alter table public.properties enable row level security;
alter table public.clients enable row level security;
alter table public.deals enable row level security;
alter table public.activities enable row level security;
alter table public.matches enable row level security;

drop policy if exists profiles_own on public.profiles;
create policy profiles_own on public.profiles
  for all using (id = auth.uid()) with check (id = auth.uid());

drop policy if exists properties_own on public.properties;
create policy properties_own on public.properties
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists clients_own on public.clients;
create policy clients_own on public.clients
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists deals_own on public.deals;
create policy deals_own on public.deals
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists activities_own on public.activities;
create policy activities_own on public.activities
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists matches_own on public.matches;
create policy matches_own on public.matches
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- =========================================================
-- Trigger: crea el profile automáticamente al registrarse
-- =========================================================

create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, nombre)
  values (new.id, coalesce(new.raw_user_meta_data->>'nombre', split_part(new.email, '@', 1)));
  return new;
end;
$$ language plpgsql security definer set search_path = public;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
