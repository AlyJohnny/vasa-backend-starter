import fs from 'fs';
import path from 'path';
import url from 'url';
import dotenv from 'dotenv';
dotenv.config();
import pool from '../src/db.js';

const __dirname = path.dirname(url.fileURLToPath(import.meta.url));
const sql = fs.readFileSync(path.join(__dirname, 'schema.sql'), 'utf8');

(async () => {
  try {
    await pool.query(sql);
    console.log('Database initialized');
    process.exit(0);
  } catch (e) {
    console.error(e);
    process.exit(1);
  }
})();
