CREATE TABLE IF NOT EXISTS producers (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  region TEXT,
  contact TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
