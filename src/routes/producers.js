import express from 'express';
import pool from '../db.js';
const router = express.Router();

// List producers
router.get('/', async (_req, res) => {
  try {
    const { rows } = await pool.query('SELECT * FROM producers ORDER BY id DESC');
    res.json(rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Create a producer
router.post('/', async (req, res) => {
  try {
    const { name, region, contact } = req.body;
    const { rows } = await pool.query(
      'INSERT INTO producers (name, region, contact) VALUES ($1, $2, $3) RETURNING *',
      [name, region, contact]
    );
    res.status(201).json(rows[0]);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

export default router;
