-- Vistas de KPIs: una sola fuente de verdad para los números del
-- dashboard (antes se recalculaban en JS en el frontend). Usan
-- security_invoker para que apliquen las mismas políticas RLS que
-- las tablas base — cada usuario solo ve sus propios KPIs.
-- create or replace view es idempotente por naturaleza.

create or replace view public.v_dashboard_kpis
with (security_invoker = true) as
select
  pr.id as user_id,
  pr.nombre,
  pr.meta_mensual,
  coalesce(props.propiedades_activas, 0) as propiedades_activas,
  coalesce(cli.leads_nuevos, 0) as leads_nuevos,
  coalesce(cli.en_negociacion, 0) as en_negociacion,
  coalesce(cli.presupuesto_negociando, 0) as presupuesto_negociando,
  coalesce(deals.cobrado, 0) as cobrado,
  coalesce(deals.tasa_promedio, 0) as tasa_promedio,
  round(coalesce(cli.presupuesto_negociando, 0) * coalesce(deals.tasa_promedio, 0)) as comision_proyectada
from public.profiles pr
left join (
  select user_id, count(*) as propiedades_activas
  from public.properties
  group by user_id
) props on props.user_id = pr.id
left join (
  select
    user_id,
    count(*) filter (where etapa = 'Contacto') as leads_nuevos,
    count(*) filter (where etapa = 'Negociando') as en_negociacion,
    sum(presupuesto) filter (where etapa = 'Negociando') as presupuesto_negociando
  from public.clients
  group by user_id
) cli on cli.user_id = pr.id
left join (
  select
    user_id,
    sum(comision) as cobrado,
    avg(case when valor > 0 then comision / valor else 0 end) as tasa_promedio
  from public.deals
  group by user_id
) deals on deals.user_id = pr.id;

grant select on public.v_dashboard_kpis to authenticated, anon;

create or replace view public.v_comisiones_por_mes
with (security_invoker = true) as
select
  user_id,
  date_trunc('month', fecha_cierre)::date as mes,
  sum(comision) as total_comision
from public.deals
group by user_id, date_trunc('month', fecha_cierre)::date;

grant select on public.v_comisiones_por_mes to authenticated, anon;
