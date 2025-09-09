-- ========== CORE ==========
CREATE TABLE IF NOT EXISTS producers (
  id           SERIAL PRIMARY KEY,
  coop_id      INTEGER,
  code         TEXT UNIQUE,
  name         TEXT NOT NULL,
  gender       TEXT CHECK (gender IN ('M','F') OR gender IS NULL),
  phone        TEXT,
  email        TEXT,
  village      TEXT,
  commune      TEXT,
  district     TEXT,
  region       TEXT,
  lat          NUMERIC(9,6),
  lng          NUMERIC(9,6),
  created_at   TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_producers_region ON producers(region);

CREATE TABLE IF NOT EXISTS parcels (
  id           SERIAL PRIMARY KEY,
  producer_id  INTEGER NOT NULL REFERENCES producers(id) ON DELETE CASCADE,
  name         TEXT,
  crop         TEXT CHECK (crop IN ('cacao','vanille','poivre','café','litchi','clou_de_girofle') OR crop IS NULL),
  area_ha      NUMERIC(10,3),
  lat          NUMERIC(9,6) NOT NULL,
  lng          NUMERIC(9,6) NOT NULL,
  planted_year INTEGER,
  created_at   TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_parcels_producer ON parcels(producer_id);
CREATE INDEX IF NOT EXISTS idx_parcels_crop     ON parcels(crop);

-- ========== CAMPAIGNS ==========
CREATE TABLE IF NOT EXISTS campaigns (
  id           SERIAL PRIMARY KEY,
  name         TEXT NOT NULL,
  crop         TEXT NOT NULL CHECK (crop IN ('cacao','vanille','poivre','café','litchi','clou_de_girofle')),
  season_year  INTEGER NOT NULL,
  start_date   DATE,
  end_date     DATE,
  status       TEXT DEFAULT 'planned' CHECK (status IN ('planned','active','closed')),
  created_at   TIMESTAMP DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_campaign ON campaigns(crop, season_year);

-- Optional: lots de récolte (raha mila)
CREATE TABLE IF NOT EXISTS harvest_lots (
  id           SERIAL PRIMARY KEY,
  producer_id  INTEGER REFERENCES producers(id) ON DELETE SET NULL,
  parcel_id    INTEGER REFERENCES parcels(id) ON DELETE SET NULL,
  campaign_id  INTEGER REFERENCES campaigns(id) ON DELETE SET NULL,
  crop         TEXT NOT NULL,
  wet_kg       NUMERIC(12,3),
  dry_kg       NUMERIC(12,3),
  quality_grade TEXT,
  moisture_pct NUMERIC(5,2),
  harvest_date DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at   TIMESTAMP DEFAULT NOW()
);

-- ========== CERTIFICATIONS ==========
CREATE TABLE IF NOT EXISTS certifications (
  id           SERIAL PRIMARY KEY,
  producer_id  INTEGER NOT NULL REFERENCES producers(id) ON DELETE CASCADE,
  scheme       TEXT NOT NULL CHECK (scheme IN ('BIO','FAIRTRADE')),
  status       TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','valid','suspended','revoked','expired')),
  cert_number  TEXT,
  org_name     TEXT,
  valid_from   DATE,
  valid_to     DATE,
  attachments  JSONB,
  created_at   TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_cert_producer ON certifications(producer_id);
CREATE INDEX IF NOT EXISTS idx_cert_status   ON certifications(status);

-- ========== MARKETPLACE ==========
CREATE TABLE IF NOT EXISTS products (
  id           SERIAL PRIMARY KEY,
  name         TEXT NOT NULL,
  crop         TEXT NOT NULL CHECK (crop IN ('cacao','vanille','poivre','café','litchi','clou_de_girofle')),
  description  TEXT,
  specs        JSONB,
  created_at   TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS offers (
  id             SERIAL PRIMARY KEY,
  product_id     INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  seller_coop_id INTEGER,
  quantity_mt    NUMERIC(12,3) NOT NULL,
  price_usd_mt   NUMERIC(12,2),
  incoterm       TEXT,            -- FOB/CIF/EXW
  available_from DATE,
  available_to   DATE,
  status         TEXT DEFAULT 'draft' CHECK (status IN ('draft','published','sold','withdrawn')),
  specs          JSONB,
  created_at     TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_offers_product ON offers(product_id);
CREATE INDEX IF NOT EXISTS idx_offers_status  ON offers(status);

-- ========== SEED MINIMAL (azo esorina raha tsy ilaina) ==========
INSERT INTO producers (code, name, region, village, phone)
SELECT 'PRD-0001','Jean Ranaivo','SAVA','Ambanja','+261340000000'
WHERE NOT EXISTS (SELECT 1 FROM producers WHERE code='PRD-0001');

INSERT INTO parcels (producer_id, name, crop, area_ha, lat, lng, planted_year)
SELECT p.id, 'Parcelle A', 'cacao', 1.25, -13.666000, 48.450000, 2018
FROM producers p WHERE p.code='PRD-0001'
AND NOT EXISTS (SELECT 1 FROM parcels WHERE producer_id=p.id AND name='Parcelle A');

INSERT INTO products (name, crop, description)
SELECT 'Cacao beans', 'cacao', 'Fermented, sun-dried'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name='Cacao beans');
