import fs from 'fs';
import pkg from 'pg';
import dotenv from 'dotenv';

dotenv.config();
const { Client } = pkg;

async function initDB() {
  const client = new Client({ connectionString: process.env.DATABASE_URL });
  try {
    await client.connect();
    console.log('Connected to DB');

    const schema = fs.readFileSync('./scripts/schema.sql', 'utf8');
    await client.query(schema);
    console.log('✅ VASA DB initialized / updated');
  } catch (err) {
    console.error('Error initializing DB:', err);
  } finally {
    await client.end();
  }
}

initDB();
