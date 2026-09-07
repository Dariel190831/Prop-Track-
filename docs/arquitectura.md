# Arquitectura de PropTrack

PropTrack es una app de gestión inmobiliaria (propiedades, clientes/pipeline
y comisiones) para agentes en San Pedro Sula, Honduras. Este documento
describe la arquitectura actual del sistema en producción.

## Diagrama de contexto (C4 · Nivel 1)

```mermaid
C4Context
    title Diagrama de Contexto (C4 Nivel 1) - PropTrack

    Person(agente, "Agente Inmobiliario", "Gestiona su cartera de propiedades, su pipeline de clientes y sus comisiones")

    System(proptrack, "PropTrack", "Dashboard de gestion inmobiliaria: propiedades con mapa, CRM de clientes y calculo de comisiones")

    System_Ext(supabase, "Supabase", "Backend como servicio: autenticacion, base de datos Postgres con RLS y API REST autogenerada")
    System_Ext(vercel, "Vercel", "Hosting estatico + funcion serverless para el healthcheck de la API")
    System_Ext(mapas, "OpenStreetMap / Esri", "Tiles de mapa (calles y satelital) para ubicar las propiedades")

    Rel(agente, proptrack, "Usa desde el navegador")
    Rel(proptrack, supabase, "Autentica, lee y escribe datos vía REST/RLS")
    Rel(proptrack, vercel, "Se sirve desde")
    Rel(proptrack, mapas, "Pide tiles del mapa")
```

## Diagrama de contenedores (C4 · Nivel 2)

```mermaid
flowchart TB
  subgraph Navegador["Navegador del agente"]
    A["index.html (shell React)"] -->|iframe| B["PropTrack.dc.html (UI real, un solo archivo)"]
    B -->|iframe| M["mapa.html (Leaflet)"]
  end

  B -->|"@supabase/supabase-js: Auth + REST"| S[("Supabase: Postgres + RLS")]
  B -->|"RPC email_exists"| S
  S --> V["Vistas SQL: v_dashboard_kpis, v_comisiones_por_mes"]

  M -->|tiles calles| OSM["OpenStreetMap"]
  M -->|tiles satelite| ESRI["Esri World Imagery"]

  VERCEL["Vercel (hosting + rewrites)"] -.sirve.-> A
  VERCEL --> HEALTH["/api/health.js (Serverless Function)"]
```

## Componentes principales

- **`index.html` / `src/App.jsx`**: shell de React que sólo monta un
  `<iframe>` a `PropTrack.dc.html`. Es el documento real servido en la
  raíz del dominio (`https://www.darielmencia.lat/`); ahí viven las
  etiquetas de SEO, Open Graph, manifest PWA y el registro del service
  worker.
- **`PropTrack.dc.html`**: la interfaz real de la aplicación (login,
  Resumen, Propiedades, Clientes, Comisiones). Ver [ADR-002](adr/ADR-002-frontend-prototipo.md)
  sobre por qué sigue siendo un solo archivo en vez de componentes React.
- **`mapa.html`**: mapa Leaflet embebido, recibe las propiedades del
  padre por `postMessage` (no tiene datos propios).
- **Supabase**: Postgres administrado con Row Level Security (cada fila
  scopeada a `user_id = auth.uid()`), Auth (email/password), y dos
  vistas (`v_dashboard_kpis`, `v_comisiones_por_mes`) que calculan los
  KPIs del dashboard como fuente única de verdad. Ver [ADR-001](adr/ADR-001-persistencia.md).
- **`supabase/migrations/`**: migraciones SQL idempotentes numeradas
  (`001_...`, `002_...`), aplicadas y registradas en
  `public.schema_migrations` por `supabase/migrate.js`.
- **Vercel**: hosting estático + rewrites (`/`, `/login`, `/admin` →
  `PropTrack.dc.html`) + una función serverless (`/api/health`).

## Decisiones de arquitectura (ADRs)

- [ADR-001 — Usar Supabase en vez de un backend propio](adr/ADR-001-persistencia.md)
- [ADR-002 — Mantener el prototipo de un solo archivo como frontend](adr/ADR-002-frontend-prototipo.md)
