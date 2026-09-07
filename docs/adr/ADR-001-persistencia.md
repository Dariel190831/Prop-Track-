# ADR-001: Usar Supabase (Postgres administrado, Auth y RLS) en vez de un backend propio

## Estado

Aceptada.

## Contexto

PropTrack arrancó como un prototipo puramente visual (`PropTrack.dc.html`):
todas las propiedades, clientes y comisiones estaban hardcodeados directo
en arrays de JavaScript dentro del HTML. Para que sirviera como una app
real hacía falta persistencia de verdad, autenticación de usuarios, y que
cada agente viera únicamente su propia cartera (multi-tenant) — sin que
los datos de un agente se mezclaran con los de otro.

El proyecto es de un solo desarrollador, con entregas semanales de clase
y sin presupuesto para infraestructura. Las opciones consideradas fueron:

1. Construir un backend propio (por ejemplo Node/Express) con su propia
   base de datos Postgres, autenticación con JWT manual, y lógica de
   autorización escrita a mano en cada endpoint.
2. Usar Supabase: Postgres administrado + Auth + Row Level Security
   (RLS) + una API REST autogenerada (PostgREST), consumida directo
   desde el frontend con su SDK de JavaScript.

## Decisión

**Usar Supabase (Postgres administrado, Auth y RLS) en vez de un backend propio.**

Toda la persistencia vive en Supabase. Las tablas (`properties`,
`clients`, `deals`, `activities`, `matches`, `profiles`) tienen políticas
de Row Level Security que exigen `user_id = auth.uid()` en cada fila, así
que la autorización se aplica dentro de la base de datos, no en código de
aplicación que alguien podría olvidar escribir en un endpoint nuevo. El
frontend llama directo a la API de Supabase usando la clave pública
(`anon key`), protegida por esas políticas — nunca hay un servidor propio
en el medio.

## Consecuencias

**Positivas:**
- Se pasó de datos hardcodeados a un backend real con autenticación,
  multiusuario y aislamiento de datos por RLS en cuestión de días, no de
  semanas.
- No hay servidor propio que desplegar, escalar, ni parchear por
  vulnerabilidades.
- Las migraciones (`supabase/migrations/`) quedan versionadas en el
  repo, son idempotentes, y se registran en una tabla de control
  (`public.schema_migrations`) igual que en cualquier framework de
  migraciones tradicional.

**Negativas (lo que se sacrificó):**
- Dependencia total de un proveedor externo: si Supabase tiene una
  caída o cambia sus límites, la app entera se ve afectada sin que
  podamos hacer nada del lado del backend.
- Parte de la lógica de negocio (por ejemplo las vistas
  `v_dashboard_kpis` y `v_comisiones_por_mes`, que calculan los KPIs del
  dashboard) vive escrita en SQL dentro de la base de datos, en vez de
  en código de aplicación versionado con el mismo lenguaje y las mismas
  herramientas de testing que el resto del proyecto.
- Los límites del plan gratuito (filas, ancho de banda, ejecuciones)
  son un techo real apenas el negocio crezca más allá de un agente de
  prueba.
