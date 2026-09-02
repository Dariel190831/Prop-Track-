-- PropTrack — datos demo (San Pedro Sula)
-- Requiere que supabase/schema.sql ya se haya ejecutado.
-- Aplica el mismo set de propiedades/clientes a cada correo en v_emails.
-- El primero de la lista es el usuario demo (se crea si no existe);
-- el resto deben ser cuentas ya registradas en la app.

do $$
declare
  v_emails text[] := array['dariel@proptrack.demo', 'darielmencia750@gmail.com'];
  v_email text;
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
  foreach v_email in array v_emails loop

    select id into v_user_id from auth.users where email = v_email;

    if v_user_id is null then
      v_user_id := gen_random_uuid();

      insert into auth.users (
        instance_id, id, aud, role, email, encrypted_password,
        email_confirmed_at, created_at, updated_at,
        raw_app_meta_data, raw_user_meta_data, confirmation_token, recovery_token,
        email_change_token_new, email_change, is_sso_user, is_anonymous
      ) values (
        '00000000-0000-0000-0000-000000000000', v_user_id, 'authenticated', 'authenticated',
        v_email, crypt('demo1234', gen_salt('bf')),
        now(), now(), now(),
        '{"provider":"email","providers":["email"]}', '{"nombre":"Dariel Mencía"}',
        '', '', '', '', false, false
      );

      insert into auth.identities (
        id, provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at
      ) values (
        gen_random_uuid(), v_user_id, v_user_id,
        jsonb_build_object('sub', v_user_id::text, 'email', v_email),
        'email', now(), now(), now()
      );
    end if;

    insert into public.profiles (id, nombre, plan, meta_mensual)
    values (v_user_id, 'Dariel Mencía', 'mensual', 120000)
    on conflict (id) do update set nombre = excluded.nombre, plan = excluded.plan, meta_mensual = excluded.meta_mensual;

    delete from public.matches where user_id = v_user_id;
    delete from public.deals where user_id = v_user_id;
    delete from public.activities where user_id = v_user_id;
    delete from public.clients where user_id = v_user_id;
    delete from public.properties where user_id = v_user_id;

    -- Propiedades (San Pedro Sula — coordenadas verificadas por barrio)
    insert into public.properties (id, user_id, titulo, zona, tipo, precio, estado, habitaciones, area, area_unidad, descripcion, lat, lng)
    values
      (gen_random_uuid(), v_user_id, 'Casa Residencial Jardines del Valle', 'Jardines del Valle', 'Casa', 3850000, 'Disponible', 3, 240, 'm2',
        'Casa moderna de dos niveles en una de las zonas residenciales más buscadas de San Pedro Sula. Jardín amplio, cochera techada para dos vehículos y acabados de lujo en cocina y baños.',
        15.5278, -88.0339),
      (gen_random_uuid(), v_user_id, 'Apartamento Torre Aria', 'El Pedregal', 'Apartamento', 2150000, 'Negociando', 2, 96, 'm2',
        'Apartamento en torre de reciente construcción con vista panorámica a la ciudad, seguridad 24/7, gimnasio y área social. Ideal para pareja joven o profesional.',
        15.5400, -88.0500),
      (gen_random_uuid(), v_user_id, 'Casa Colonia Trejo', 'La Trejo', 'Casa', 1980000, 'Disponible', 3, 180, 'm2',
        'Casa familiar de un nivel en colonia tradicional y consolidada, cerca de centros educativos y comerciales. Patio trasero amplio, ideal para ampliación.',
        15.4850, -88.0450),
      (gen_random_uuid(), v_user_id, 'Local comercial Río de Piedras', 'Río de Piedras', 'Local', 4400000, 'Vendida', null, 320, 'm2',
        'Local comercial de dos plantas sobre vía principal con alto flujo vehicular y peatonal. Excelente para restaurante, farmacia o sucursal bancaria.',
        15.4750, -88.0500),
      (gen_random_uuid(), v_user_id, 'Terreno Rivera Hernández', 'Rivera Hernández', 'Terreno', 950000, 'Disponible', null, 1100, 'v2',
        'Terreno plano y esquinero, listo para construir, con todos los servicios básicos disponibles en el sector. Buena plusvalía por el crecimiento habitacional de la zona.',
        15.4726, -87.9493),
      (gen_random_uuid(), v_user_id, 'Apartamento Moderna 402', 'Colonia Moderna', 'Apartamento', 2650000, 'Disponible', 2, 110, 'm2',
        'Apartamento remodelado en colonia céntrica, a pasos de supermercados y transporte público. Balcón con vista a la calle y closets empotrados en ambas habitaciones.',
        15.5150, -88.0250),
      (gen_random_uuid(), v_user_id, 'Casa Las Acacias', 'Las Acacias', 'Casa', 2300000, 'Vendida', 3, 210, 'm2',
        'Residencial cerrado con vigilancia privada, áreas verdes comunes y parque infantil. Casa esquinera con doble entrada vehicular.',
        15.5350, -87.9900),
      (gen_random_uuid(), v_user_id, 'Terreno Merendón Hills', 'Merendón Hills', 'Terreno', 780000, 'Vendida', null, 1500, 'v2',
        'Terreno en las faldas del Merendón con clima fresco y vista a la ciudad, ideal para proyecto residencial exclusivo o casa de descanso.',
        15.5500, -88.0800);

    select id into v_prop_andes    from public.properties where user_id = v_user_id and titulo = 'Casa Residencial Jardines del Valle';
    select id into v_prop_aria     from public.properties where user_id = v_user_id and titulo = 'Apartamento Torre Aria';
    select id into v_prop_trejo    from public.properties where user_id = v_user_id and titulo = 'Casa Colonia Trejo';
    select id into v_prop_piedras  from public.properties where user_id = v_user_id and titulo = 'Local comercial Río de Piedras';
    select id into v_prop_hatillo  from public.properties where user_id = v_user_id and titulo = 'Terreno Rivera Hernández';
    select id into v_prop_palmira  from public.properties where user_id = v_user_id and titulo = 'Apartamento Moderna 402';
    select id into v_prop_mayab    from public.properties where user_id = v_user_id and titulo = 'Casa Las Acacias';
    select id into v_prop_angeles  from public.properties where user_id = v_user_id and titulo = 'Terreno Merendón Hills';

    -- Clientes / pipeline
    insert into public.clients (id, user_id, nombre, busca, presupuesto, etapa, created_at)
    values
      (gen_random_uuid(), v_user_id, 'Daysi Ramírez', 'Apartamento en El Pedregal',           2000000, 'Contacto',   now() - interval '3 days'),
      (gen_random_uuid(), v_user_id, 'Luis Fajardo',  'Terreno en Rivera Hernández',          900000,  'Contacto',   now() - interval '5 days'),
      (gen_random_uuid(), v_user_id, 'Carlos Mejía',  'Casa 3 hab en Jardines del Valle',     3900000, 'Visita',     now() - interval '8 days'),
      (gen_random_uuid(), v_user_id, 'Ana Cruz',      'Apartamento amueblado en Col. Moderna', 2200000, 'Visita',     now() - interval '11 days'),
      (gen_random_uuid(), v_user_id, 'Roberto Paz',   'Casa en La Trejo',                     1900000, 'Negociando', now() - interval '18 days'),
      (gen_random_uuid(), v_user_id, 'Inversiones RG','Local comercial en Río de Piedras',    4400000, 'Cerrado',    now() - interval '30 days');

    select id into v_cli_daysi   from public.clients where user_id = v_user_id and nombre = 'Daysi Ramírez';
    select id into v_cli_luis    from public.clients where user_id = v_user_id and nombre = 'Luis Fajardo';
    select id into v_cli_carlos  from public.clients where user_id = v_user_id and nombre = 'Carlos Mejía';
    select id into v_cli_ana     from public.clients where user_id = v_user_id and nombre = 'Ana Cruz';
    select id into v_cli_roberto from public.clients where user_id = v_user_id and nombre = 'Roberto Paz';
    select id into v_cli_rg      from public.clients where user_id = v_user_id and nombre = 'Inversiones RG';

    -- Comisiones / operaciones cerradas
    insert into public.deals (user_id, property_id, client_id, cliente_nombre, valor, comision, fecha_cierre)
    values
      (v_user_id, v_prop_piedras, v_cli_rg,  'Inversiones RG',  4400000, 176000, date '2026-07-15'),
      (v_user_id, v_prop_mayab,   null,      'Familia Zelaya',  2300000, 92000,  date '2026-06-10'),
      (v_user_id, v_prop_aria,    v_cli_ana, 'Ana Cruz',        2150000, 86000,  date '2026-05-20'),
      (v_user_id, v_prop_angeles, null,      'M. Discua',       780000,  31200,  date '2026-04-05');

    -- Actividad reciente
    insert into public.activities (user_id, texto, tipo, created_at)
    values
      (v_user_id, 'Roberto Paz visitó Casa Colonia Trejo', 'success', now() - interval '2 hours'),
      (v_user_id, 'Nuevo lead: Daysi Ramírez, interesada en El Pedregal', 'info', now() - interval '3 hours'),
      (v_user_id, 'Recordatorio de pago enviado a 2 clientes', 'info', now() - interval '5 hours'),
      (v_user_id, 'Local Río de Piedras marcado como vendido', 'warning', now() - interval '7 days');

    -- Sugerencias de emparejamiento (IA)
    insert into public.matches (user_id, client_id, property_id, score)
    values
      (v_user_id, v_cli_roberto, v_prop_trejo, 94),
      (v_user_id, v_cli_carlos,  v_prop_andes, 86),
      (v_user_id, v_cli_ana,     v_prop_aria,  78);

  end loop;
end $$;
