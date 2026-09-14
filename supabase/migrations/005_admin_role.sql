-- Rol de administrador: ve en modo lectura la cartera de TODOS los
-- vendedores (properties, clients, deals, activities, matches), sin
-- poder editar ni eliminar lo que no es suyo -- las politicas "_own" ya
-- existentes siguen siendo las unicas que permiten escritura.
--
-- No hay flujo de registro para elegir el rol a proposito (evita que
-- cualquiera se autoasigne admin). Se activa a mano, una vez, corriendo
-- en el SQL editor de Supabase:
--   update public.profiles set role = 'admin' where id =
--     (select id from auth.users where email = 'tu-correo@ejemplo.com');

alter table public.profiles
  add column if not exists role text not null default 'agente' check (role in ('agente','admin'));

-- security definer: sin esto, una politica en profiles que consulte
-- profiles para saber el rol del usuario actual entra en RLS de nuevo
-- sobre si misma (recursion). La funcion corre con los privilegios del
-- dueno (bypass RLS) solo para esta lectura puntual del propio rol.
create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select coalesce((select role = 'admin' from public.profiles where id = auth.uid()), false);
$$;

revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to authenticated;

-- Politicas de solo lectura adicionales para admin: postgres combina
-- varias politicas permisivas del mismo comando con OR, asi que una fila
-- queda visible si el usuario es su dueno (politica "_own") O si es
-- admin (politica de abajo) -- ninguna de las dos toca INSERT/UPDATE/DELETE.
drop policy if exists profiles_admin_read on public.profiles;
create policy profiles_admin_read on public.profiles
  for select using (public.is_admin());

drop policy if exists properties_admin_read on public.properties;
create policy properties_admin_read on public.properties
  for select using (public.is_admin());

drop policy if exists clients_admin_read on public.clients;
create policy clients_admin_read on public.clients
  for select using (public.is_admin());

drop policy if exists deals_admin_read on public.deals;
create policy deals_admin_read on public.deals
  for select using (public.is_admin());

drop policy if exists activities_admin_read on public.activities;
create policy activities_admin_read on public.activities
  for select using (public.is_admin());

drop policy if exists matches_admin_read on public.matches;
create policy matches_admin_read on public.matches
  for select using (public.is_admin());
