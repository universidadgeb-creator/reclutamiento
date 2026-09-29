-- Permite que el formulario público (solicitud-vacante.html) cree filas en la MISMA tabla vacantes_2026.
-- Ejecutar una sola vez en Supabase > SQL Editor.

-- 1) Columnas nuevas para las preguntas de la requisición que la tabla aún no tenía.
--    NOTA: esta tabla la lee el portal con la llave pública, así que cualquier dato guardado aquí
--    es visible para quien tenga esa llave. Por eso "solicitante_datos" pide nombre/puesto/contacto
--    de trabajo: no pidas datos personales sensibles.
alter table public.vacantes_2026
  add column if not exists solicitante_datos        text,
  add column if not exists fecha_requerida_ingreso  date,
  add column if not exists prioridad                text,
  add column if not exists tipo_requisicion         text,
  add column if not exists justificacion            text,
  add column if not exists escolaridad              text,
  add column if not exists personal_requerido       text,
  add column if not exists experiencia              text,
  add column if not exists certificaciones          text,
  add column if not exists competencias             text,
  add column if not exists descanso                 text,
  add column if not exists bono                     text,
  add column if not exists prestaciones             text,
  add column if not exists funciones                text,
  add column if not exists autorizacion             text;

-- 2) Las solicitudes llegan sin reclutador (y a veces sin unidad, si la sucursal es nueva):
--    esas columnas deben aceptar nulos.
alter table public.vacantes_2026 alter column reclutador     drop not null;
alter table public.vacantes_2026 alter column unidad_negocio drop not null;

-- 3) El formulario (anon) solo puede INSERTAR filas con estatus 'POR ASIGNAR' y sin reclutador.
--    No puede editar ni borrar nada.
alter table public.vacantes_2026 enable row level security;

drop policy if exists "anon envia solicitud de vacante" on public.vacantes_2026;
create policy "anon envia solicitud de vacante"
  on public.vacantes_2026
  for insert to anon
  with check (estatus = 'POR ASIGNAR' and reclutador is null);

grant insert on public.vacantes_2026 to anon;

-- 4) La tabla tiene un CHECK sobre "estatus" (vacantes_2026_estatus_check) que no acepta 'POR ASIGNAR'.
--    Se reemplaza por uno que incluye todos los estatus que usa el portal.
alter table public.vacantes_2026 drop constraint if exists vacantes_2026_estatus_check;
alter table public.vacantes_2026
  add constraint vacantes_2026_estatus_check
  check (estatus in ('ACTIVA','CUBIERTA','EN PAUSA','CANCELADA','POR ASIGNAR'));
