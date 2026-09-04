-- Agrega la descripción libre de cada propiedad (se muestra al
-- expandir la tarjeta en la app y en el popup del mapa).

alter table public.properties add column if not exists descripcion text;
