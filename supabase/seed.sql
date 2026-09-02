-- PropTrack — usuario demo y datos de ejemplo
-- Requiere que supabase/schema.sql ya se haya ejecutado.
-- Usuario demo: dariel@proptrack.demo / demo1234

do $$
declare
  v_user_id uuid;
  v_prop_andes uuid;
  v_prop_aria uuid;
  v_prop_trejo uuid;
  v_prop_piedras uuid;
  v_prop_hatillo uuid;
  v_prop_palmira uuid;
  v_prop_mayab uuid;
  v_prop_angeles uuid;
  v_cli_daysi uuid;
  v_cli_luis uuid;
  v_cli_carlos uuid;
  v_cli_ana uuid;
  v_cli_roberto uuid;
  v_cli_rg uuid;
begin
  -- 1) Usuario demo (auth.users + auth.identities)
  select id into v_user_id from auth.users where email = 'dariel@proptrack.demo';

  if v_user_id is null then
    v_user_id := gen_random_uuid();

    insert into auth.users (
      instance_id, id, aud, role, email, encrypted_password,
      email_confirmed_at, created_at, updated_at,
      raw_app_meta_data, raw_user_meta_data, confirmation_token, recovery_token,
      email_change_token_new, email_change, is_sso_user, is_anonymous
    ) values (
      '00000000-0000-0000-0000-000000000000', v_user_id, 'authenticated', 'authenticated',
      'dariel@proptrack.demo', crypt('demo1234', gen_salt('bf')),
      now(), now(), now(),
      '{"provider":"email","providers":["email"]}', '{"nombre":"Dariel Mencía"}',
      '', '', '', '', false, false
    );

    insert into auth.identities (
      id, provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at
    ) values (
      gen_random_uuid(), v_user_id, v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', 'dariel@proptrack.demo'),
      'email', now(), now(), now()
    );
  end if;

  -- 2) Profile (el trigger ya lo crea al insertar en auth.users; lo forzamos por si ya existía)
  insert into public.profiles (id, nombre, plan, meta_mensual)
  values (v_user_id, 'Dariel Mencía', 'mensual', 120000)
  on conflict (id) do update set nombre = excluded.nombre, plan = excluded.plan, meta_mensual = excluded.meta_mensual;

  -- limpiar datos demo previos de este usuario (permite re-correr el script)
  delete from public.matches where user_id = v_user_id;
  delete from public.deals where user_id = v_user_id;
  delete from public.activities where user_id = v_user_id;
  delete from public.clients where user_id = v_user_id;
  delete from public.properties where user_id = v_user_id;

  -- 3) Propiedades (San Pedro Sula)
  insert into public.properties (id, user_id, titulo, zona, tipo, precio, estado, habitaciones, area, area_unidad, lat, lng)
  values
    (gen_random_uuid(), v_user_id, 'Casa Residencial Jardines del Valle', 'Jardines del Valle', 'Casa', 3850000, 'Disponible', 3, 240, 'm2', 15.5250, -88.0550),
    (gen_random_uuid(), v_user_id, 'Apartamento Torre Aria', 'El Pedregal', 'Apartamento', 2150000, 'Negociando', 2, 96, 'm2', 15.5400, -88.0650),
    (gen_random_uuid(), v_user_id, 'Casa Colonia Trejo', 'La Trejo', 'Casa', 1980000, 'Disponible', 3, 180, 'm2', 15.4850, -88.0450),
    (gen_random_uuid(), v_user_id, 'Local comercial Río de Piedras', 'Río de Piedras', 'Local', 4400000, 'Vendida', null, 320, 'm2', 15.4750, -88.0600),
    (gen_random_uuid(), v_user_id, 'Terreno Rivera Hernández', 'Rivera Hernández', 'Terreno', 950000, 'Disponible', null, 1100, 'v2', 15.4700, -87.9950),
    (gen_random_uuid(), v_user_id, 'Apartamento Moderna 402', 'Colonia Moderna', 'Apartamento', 2650000, 'Disponible', 2, 110, 'm2', 15.5150, -88.0350),
    (gen_random_uuid(), v_user_id, 'Casa Las Acacias', 'Las Acacias', 'Casa', 2300000, 'Vendida', 3, 210, 'm2', 15.5350, -87.9900),
    (gen_random_uuid(), v_user_id, 'Terreno Merendón Hills', 'Merendón Hills', 'Terreno', 780000, 'Vendida', null, 1500, 'v2', 15.5500, -88.0800);

  select id into v_prop_andes    from public.properties where user_id = v_user_id and titulo = 'Casa Residencial Jardines del Valle';
  select id into v_prop_aria     from public.properties where user_id = v_user_id and titulo = 'Apartamento Torre Aria';
  select id into v_prop_trejo    from public.properties where user_id = v_user_id and titulo = 'Casa Colonia Trejo';
  select id into v_prop_piedras  from public.properties where user_id = v_user_id and titulo = 'Local comercial Río de Piedras';
  select id into v_prop_hatillo  from public.properties where user_id = v_user_id and titulo = 'Terreno Rivera Hernández';
  select id into v_prop_palmira  from public.properties where user_id = v_user_id and titulo = 'Apartamento Moderna 402';
  select id into v_prop_mayab    from public.properties where user_id = v_user_id and titulo = 'Casa Las Acacias';
  select id into v_prop_angeles  from public.properties where user_id = v_user_id and titulo = 'Terreno Merendón Hills';

  -- 4) Clientes / pipeline (created_at ajustado para simular "días en etapa")
  insert into public.clients (id, user_id, nombre, busca, presupuesto, etapa, created_at)
  values
    (gen_random_uuid(), v_user_id, 'Daysi Ramírez', 'Apartamento en El Pedregal',        2000000, 'Contacto',   now() - interval '3 days'),
    (gen_random_uuid(), v_user_id, 'Luis Fajardo',  'Terreno en Rivera Hernández',       900000,  'Contacto',   now() - interval '5 days'),
    (gen_random_uuid(), v_user_id, 'Carlos Mejía',  'Casa 3 hab, Jardines del Valle',    3900000, 'Visita',     now() - interval '8 days'),
    (gen_random_uuid(), v_user_id, 'Ana Cruz',      'Apartamento amueblado',             2200000, 'Visita',     now() - interval '11 days'),
    (gen_random_uuid(), v_user_id, 'Roberto Paz',   'Casa Colonia Trejo',                1900000, 'Negociando', now() - interval '18 days'),
    (gen_random_uuid(), v_user_id, 'Inversiones RG','Local Río de Piedras',              4400000, 'Cerrado',    now() - interval '30 days');

  select id into v_cli_daysi   from public.clients where user_id = v_user_id and nombre = 'Daysi Ramírez';
  select id into v_cli_luis    from public.clients where user_id = v_user_id and nombre = 'Luis Fajardo';
  select id into v_cli_carlos  from public.clients where user_id = v_user_id and nombre = 'Carlos Mejía';
  select id into v_cli_ana     from public.clients where user_id = v_user_id and nombre = 'Ana Cruz';
  select id into v_cli_roberto from public.clients where user_id = v_user_id and nombre = 'Roberto Paz';
  select id into v_cli_rg      from public.clients where user_id = v_user_id and nombre = 'Inversiones RG';

  -- 5) Comisiones / operaciones cerradas
  insert into public.deals (user_id, property_id, client_id, cliente_nombre, valor, comision, fecha_cierre)
  values
    (v_user_id, v_prop_piedras, v_cli_rg,  'Inversiones RG',  4400000, 176000, date '2026-07-15'),
    (v_user_id, v_prop_mayab,   null,      'Familia Zelaya',  2300000, 92000,  date '2026-06-10'),
    (v_user_id, v_prop_aria,    v_cli_ana, 'Ana Cruz',        2150000, 86000,  date '2026-05-20'),
    (v_user_id, v_prop_angeles, null,      'M. Discua',       780000,  31200,  date '2026-04-05');

  -- 6) Actividad reciente
  insert into public.activities (user_id, texto, tipo, created_at)
  values
    (v_user_id, 'Roberto Paz visitó Casa Colonia Trejo', 'success', now() - interval '2 hours'),
    (v_user_id, 'Nuevo lead: Daysi Ramírez, interesada en El Pedregal', 'info', now() - interval '3 hours'),
    (v_user_id, 'Recordatorio de pago enviado a 2 clientes', 'info', now() - interval '5 hours'),
    (v_user_id, 'Local Río de Piedras marcado como vendido', 'warning', now() - interval '7 days');

  -- 7) Sugerencias de emparejamiento (IA)
  insert into public.matches (user_id, client_id, property_id, score)
  values
    (v_user_id, v_cli_roberto, v_prop_trejo, 94),
    (v_user_id, v_cli_carlos,  v_prop_andes, 86),
    (v_user_id, v_cli_ana,     v_prop_aria,  78);

end $$;
