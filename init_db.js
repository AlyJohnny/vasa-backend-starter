import fs from "fs";
import path from "path";
import url from "url";
import dotenv from "dotenv";
import pkg from "pg";

dotenv.config();
const { Client } = pkg;

const __dirname = path.dirname(url.fileURLToPath(import.meta.url));
const sql = fs.readFileSync(path.join(__dirname, "schema.sql"), "utf8");

(async () => {
  const client = new Client({
    connectionString: process.env.DATABASE_URL,
    ssl: { rejectUnauthorized: false }, // ilaina amin'ny Railway PG
  });
  try {
    await client.connect();
    await client.query(sql);
    console.log("✅ DB initialized / updated");
    process.exit(0);
  } catch (e) {
    console.error("❌ DB init error:", e.message);
    process.exit(1);
  } finally {
    await client.end();
  }
})();
