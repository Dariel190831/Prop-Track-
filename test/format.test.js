import { describe, expect, it } from "vitest";
import { esc, fmtArea, fmtDias, fmtFecha, fmtHace, fmtL, MESES_ABR, VARA2_A_M2 } from "../src/format.js";

describe("fmtL", () => {
  it("formatea números como Lempiras con separador de miles", () => {
    expect(fmtL(3850000)).toBe("L. 3,850,000");
    expect(fmtL(950000)).toBe("L. 950,000");
  });

  it("redondea decimales", () => {
    expect(fmtL(76000.4)).toBe("L. 76,000");
    expect(fmtL(76000.6)).toBe("L. 76,001");
  });

  it("trata valores inválidos como cero", () => {
    expect(fmtL(null)).toBe("L. 0");
    expect(fmtL(undefined)).toBe("L. 0");
    expect(fmtL(NaN)).toBe("L. 0");
  });
});

describe("fmtArea", () => {
  it("formatea metros cuadrados sin conversión", () => {
    expect(fmtArea(240, "m2")).toBe("240 m²");
  });

  it("convierte varas² a m² usando el factor hondureño", () => {
    const resultado = fmtArea(1100, "v2");
    expect(resultado).toContain("1,100 v²");
    expect(resultado).toContain(`${Math.round(1100 * VARA2_A_M2)} m²`);
  });

  it("devuelve cadena vacía sin área", () => {
    expect(fmtArea(null, "m2")).toBe("");
    expect(fmtArea(0, "v2")).toBe("");
  });
});

describe("fmtDias", () => {
  it("dice 'hoy' si la fecha es de hace menos de un día", () => {
    expect(fmtDias(new Date().toISOString())).toBe("hoy");
  });

  it("cuenta días completos transcurridos", () => {
    const hace3dias = new Date(Date.now() - 3 * 86400000).toISOString();
    expect(fmtDias(hace3dias)).toBe("3 d");
  });
});

describe("fmtHace", () => {
  it("muestra minutos cuando es reciente", () => {
    const hace5min = new Date(Date.now() - 5 * 60000).toISOString();
    expect(fmtHace(hace5min)).toBe("hace 5 min");
  });

  it("muestra horas cuando pasó más de una hora", () => {
    const hace2h = new Date(Date.now() - 2 * 3600000).toISOString();
    expect(fmtHace(hace2h)).toBe("hace 2 h");
  });

  it("muestra semanas (con plural) cuando pasó más de una semana", () => {
    const hace2semanas = new Date(Date.now() - 15 * 86400000).toISOString();
    expect(fmtHace(hace2semanas)).toBe("hace 2 semanas");
  });
});

describe("fmtFecha", () => {
  it("formatea como 'D MES AAAA' usando los meses en español abreviados", () => {
    const fecha = new Date(2026, 7, 11); // agosto (índice 7) es "AGO"
    expect(fmtFecha(fecha)).toBe(`11 ${MESES_ABR[7]} 2026`);
  });
});

describe("esc", () => {
  it("escapa caracteres HTML para evitar inyección al interpolar en el mapa", () => {
    expect(esc('<script>alert("x")</script>')).toBe(
      "&lt;script&gt;alert(&quot;x&quot;)&lt;/script&gt;"
    );
  });

  it("devuelve cadena vacía para null/undefined", () => {
    expect(esc(null)).toBe("");
    expect(esc(undefined)).toBe("");
  });
});
