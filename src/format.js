// Funciones de formato usadas por el dashboard (PropTrack.dc.html):
// moneda en Lempiras, conversión de varas² a m², fechas relativas y
// fecha corta. Se extraen aquí como módulo aparte para poder cubrirlas
// con pruebas unitarias (ver test/format.test.js).

export const VARA2_A_M2 = 0.6987; // 1 vara² hondureña ≈ 0.6987 m²

export const MESES_ABR = ["ENE", "FEB", "MAR", "ABR", "MAY", "JUN", "JUL", "AGO", "SEP", "OCT", "NOV", "DIC"];

export function fmtL(n) {
  return "L. " + Math.round(Number(n) || 0).toLocaleString("en-US");
}

export function fmtArea(area, unidad) {
  if (!area) return "";
  if (unidad === "v2") {
    const m2 = Math.round(area * VARA2_A_M2);
    return `${Number(area).toLocaleString("en-US")} v² (≈ ${m2.toLocaleString("en-US")} m²)`;
  }
  return `${Number(area).toLocaleString("en-US")} m²`;
}

export function fmtDias(iso) {
  const days = Math.max(0, Math.floor((Date.now() - new Date(iso).getTime()) / 86400000));
  return days === 0 ? "hoy" : `${days} d`;
}

export function fmtFecha(date) {
  return `${date.getDate()} ${MESES_ABR[date.getMonth()]} ${date.getFullYear()}`;
}

export function fmtHace(iso) {
  const mins = Math.max(1, Math.floor((Date.now() - new Date(iso).getTime()) / 60000));
  if (mins < 60) return `hace ${mins} min`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24) return `hace ${hrs} h`;
  const days = Math.floor(hrs / 24);
  if (days < 7) return `hace ${days} d`;
  const semanas = Math.floor(days / 7);
  return `hace ${semanas} semana${semanas > 1 ? "s" : ""}`;
}

export function esc(s) {
  return String(s ?? "").replace(/[&<>"']/g, (c) => ({
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    '"': "&quot;",
    "'": "&#39;",
  }[c]));
}
