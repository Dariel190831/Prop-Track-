# PropTrack

Proyecto de clase ISW2 para la gestión inmobiliaria.

## Desarrollo

```bash
npm install
npm run dev
```

La aplicación React se sirve en la raíz. El prototipo original está disponible en `/PropTrack.dc.html`.

## Base de datos (Supabase)

El esquema vive en `supabase/migrations/`, un archivo `.sql` por cambio,
nombrados `AAAAMMDDHHMMSS_descripcion.sql` para que se apliquen en orden.
Cada script es idempotente (`create table if not exists`, `create or
replace view/function`, `drop policy if exists` + `create policy`, etc.),
así que correrlos de nuevo no duplica ni rompe nada.

```bash
DATABASE_URL="postgresql://...pooler.supabase.com:5432/postgres" npm run migrate
```

Esto crea (si no existe) `public.schema_migrations` y aplica solo las
migraciones que todavía no estén registradas ahí — queda un historial de
qué se aplicó y cuándo, directamente en la base de datos.

Los datos demo (San Pedro Sula) están en `supabase/seed.sql` — no es una
migración de esquema, se corre aparte y es seguro repetirlo (borra y
vuelve a insertar el set completo por cada correo listado en el script).
Pégalo tal cual en el SQL Editor de Supabase, o con `psql`/`pg` apuntando
al mismo `DATABASE_URL`.

Los KPIs del dashboard (`v_dashboard_kpis`, `v_comisiones_por_mes`) son
vistas SQL, no se calculan en el frontend — una sola fuente de verdad.
