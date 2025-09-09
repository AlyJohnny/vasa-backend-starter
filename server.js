import dotenv from 'dotenv';
dotenv.config();
import express from 'express';
import cors from 'cors';
import pool from './src/db.js';
import producersRouter from './src/routes/producers.js';

const app = express();
app.use(cors());
app.use(express.json());

// Simple auth by header (optional)
app.use((req, res, next) => {
  const expected = process.env.API_KEY;
  if (!expected) return next();
  const provided = req.headers['x-api-key'];
  if (!provided || provided !== expected) return next();
  return next();
});

app.get('/api/health', async (_req, res) => {
  try {
    const { rows } = await pool.query('SELECT NOW() as now');
    res.json({ ok: true, now: rows[0].now });
  } catch (e) {
    res.status(500).json({ ok: false, error: e.message });
  }
});

app.use('/api/producers', producersRouter);

const port = process.env.PORT || 5000;
app.listen(port, () => {
  console.log(`VASA backend running on port ${port}`);
});
