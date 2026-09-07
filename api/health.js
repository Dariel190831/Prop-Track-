// Healthcheck de la API — Vercel Serverless Function, zero-config
// (cualquier archivo bajo /api se despliega como función independiente).
export default function handler(req, res) {
  res.status(200).json({
    status: "ok",
    service: "proptrack",
    time: new Date().toISOString(),
  });
}
