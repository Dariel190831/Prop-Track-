-- Login por nombre de usuario (ademas de correo): el username es
-- opcional, se guarda al registrarse via el trigger handle_new_user.
-- Si una cuenta no definio username, solo puede entrar con correo.

alter table public.profiles
  add column if not exists username text unique;

-- RPC: boolean, se usa en el registro para avisar "ese usuario ya existe"
-- antes de intentar el signUp (mismo patron que email_exists).
create or replace function public.username_exists(p_username text)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles where lower(username) = lower(p_username)
  );
$$;

revoke all on function public.username_exists(text) from public;
grant execute on function public.username_exists(text) to anon, authenticated;

-- RPC: resuelve el correo asociado a un username para poder llamar
-- sb.auth.signInWithPassword({ email, password }) sin que la persona
-- tenga que escribir su correo. Security definer + solo devuelve el
-- correo (no expone mas columnas de profiles ni de auth.users).
create or replace function public.email_by_username(p_username text)
returns text
language sql
security definer
set search_path = public, auth
as $$
  select u.email
  from public.profiles p
  join auth.users u on u.id = p.id
  where lower(p.username) = lower(p_username)
  limit 1;
$$;

revoke all on function public.email_by_username(text) from public;
grant execute on function public.email_by_username(text) to anon, authenticated;

-- El trigger ahora tambien guarda el username si vino en el signUp
-- (options.data.username). Si no vino, queda null.
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, nombre, username)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'nombre', split_part(new.email, '@', 1)),
    nullif(lower(trim(new.raw_user_meta_data->>'username')), '')
  )
  on conflict (id) do nothing;
  return new;
end;
$$ language plpgsql security definer set search_path = public;
