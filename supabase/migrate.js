// Aplica las migraciones de supabase/migrations en orden, y registra
// cada una en public.schema_migrations para no volver a correrlas.
// Uso:
//   DATABASE_URL="postgresql://...pooler.supabase.com:5432/postgres" node supabase/migrate.js
import { readdirSync, readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import pg from "pg";

const __dirname = dirname(fileURLToPath(import.meta.url));
const MIGRATIONS_DIR = join(__dirname, "migrations");

const connectionString = process.env.DATABASE_URL;
if (!connectionString) {
  console.error("Falta DATABASE_URL (connection string de Postgres, ej. el 'Session pooler' de Supabase).");
  console.error('Uso: DATABASE_URL="postgresql://..." node supabase/migrate.js');
  process.exit(1);
}

const client = new pg.Client({ connectionString, ssl: { rejectUnauthorized: false } });

async function main() {
  await client.connect();

  await client.query(`
    create table if not exists public.schema_migrations (
      version text primary key,
      applied_at timestamptz not null default now()
    );
  `);

  const applied = new Set(
    (await client.query("select version from public.schema_migrations")).rows.map((r) => r.version)
  );

  const files = readdirSync(MIGRATIONS_DIR)
    .filter((f) => f.endsWith(".sql"))
    .sort();

  let appliedCount = 0;
  for (const file of files) {
    const version = file.replace(/\.sql$/, "");
    if (applied.has(version)) {
      console.log(`skip   ${file} (ya aplicada)`);
      continue;
    }
    const sql = readFileSync(join(MIGRATIONS_DIR, file), "utf8");
    console.log(`apply  ${file}`);
    try {
      await client.query("BEGIN");
      await client.query(sql);
      await client.query("insert into public.schema_migrations (version) values ($1)", [version]);
      await client.query("COMMIT");
      appliedCount++;
    } catch (e) {
      await client.query("ROLLBACK");
      throw new Error(`Fallo en ${file}: ${e.message}`);
    }
  }

  console.log(appliedCount ? `\n${appliedCount} migración(es) aplicada(s).` : "\nYa estaba al día, nada que aplicar.");
  await client.end();
}

main().catch(async (e) => {
  console.error("MIGRATE FAIL:", e.message);
  try {
    await client.end();
  } catch {
    // conexión ya cerrada
  }
  process.exit(1);
});
