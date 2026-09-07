# ADR-002: Mantener el prototipo de un solo archivo como frontend en producción

## Estado

Aceptada.

## Contexto

El repositorio tiene dos "frontends" candidatos:

1. Una app React estándar (`src/App.jsx`, montada desde `index.html`),
   que hoy en día solo renderiza un `<iframe>`.
2. Un prototipo de diseño de una sola página (`PropTrack.dc.html`),
   generado originalmente como mockup visual sobre un runtime propio
   (`support.js`) que interpreta un DSL de plantillas (`sc-if`,
   `sc-for`, bindings `{{ }}`) sobre una clase `Component extends
   DCLogic`, sin pasar por el bundler de Vite.

Al momento de conectar la aplicación a datos reales de Supabase, había
que decidir entre migrar todo ese prototipo a componentes React de
verdad, o dejarlo tal cual y conectarlo directo a la base de datos.

## Decisión

**Mantener `PropTrack.dc.html` como el frontend real en producción**,
cargando el SDK de Supabase por un `<script>` de CDN (ya que el archivo
no pasa por el bundler de Vite) y reemplazando los arrays hardcodeados
por consultas reales dentro de los métodos del componente
(`componentDidMount`, `loadAll`), en vez de reescribir la interfaz
completa como componentes React.

## Consecuencias

**Positivas:**
- Se conservó intacto todo el diseño visual ya definido (layout,
  tipografía, color, animaciones) sin el riesgo ni el tiempo de una
  reescritura completa desde cero.
- Cada función nueva (login real con Supabase Auth, CRUD de
  propiedades y clientes, buscador global, edición de propiedades,
  cache local) se agregó de forma incremental sobre el mismo archivo,
  probando cada cambio de punta a punta contra la base de datos real
  antes de subirlo.

**Negativas (lo que se sacrificó):**
- El archivo es enorme y monolítico: toda la lógica de la aplicación
  vive en un único `<script>`, sin componentización real ni tipos.
- Es muy difícil escribir pruebas unitarias directas sobre esa lógica,
  porque está embebida en un DSL propietario y no en módulos de
  JavaScript importables — por eso funciones puras como el formato de
  moneda o la conversión de varas² a m² se extrajeron aparte a
  `src/format.js`, solo para poder cubrirlas con tests.
- Cualquier persona nueva en el equipo necesita entender primero el
  runtime propietario (`support.js`) antes de poder tocar la interfaz,
  algo que no pasaría si la UI fuera React puro desde el principio.
