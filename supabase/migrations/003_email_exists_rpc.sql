-- RPC: verifica si un correo ya está registrado (solo boolean, no
-- expone más datos). Se usa en el login para distinguir "no tenés
-- cuenta, registrate" de "contraseña incorrecta".

create or replace function public.email_exists(p_email text)
returns boolean
language sql
security definer
set search_path = public, auth
as $$
  select exists (
    select 1 from auth.users where lower(email) = lower(p_email)
  );
$$;

revoke all on function public.email_exists(text) from public;
grant execute on function public.email_exists(text) to anon, authenticated;
