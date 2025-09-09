-- VASA Trace Database Initialization Script
-- Drop existing tables (safety for dev only)
DROP TABLE IF EXISTS audit_logs, documents, offers, products,
    deforestation_checks, certifications, farm_inspections,
    harvest_lots, campaigns, parcels, producers, coops, users CASCADE;

-- Core organizational entities
CREATE TABLE coops (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    region TEXT,
    contact TEXT
);

CREATE TABLE producers (
    id SERIAL PRIMARY KEY,
    coop_id INT REFERENCES coops(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    region TEXT,
    contact TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE parcels (
    id SERIAL PRIMARY KEY,
    producer_id INT REFERENCES producers(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    crop TEXT NOT NULL, -- cacao, poivre, vanille, etc.
    lat DOUBLE PRECISION,
    lng DOUBLE PRECISION,
    area_ha NUMERIC,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Campaigns and harvest lots
CREATE TABLE campaigns (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    year INT NOT NULL,
    start_date DATE,
    end_date DATE
);

CREATE TABLE harvest_lots (
    id SERIAL PRIMARY KEY,
    campaign_id INT REFERENCES campaigns(id) ON DELETE CASCADE,
    parcel_id INT REFERENCES parcels(id) ON DELETE SET NULL,
    wet_kg NUMERIC,
    dry_kg NUMERIC,
    quality TEXT,
    moisture NUMERIC,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Inspections and certifications
CREATE TABLE farm_inspections (
    id SERIAL PRIMARY KEY,
    parcel_id INT REFERENCES parcels(id) ON DELETE CASCADE,
    inspector TEXT,
    date DATE,
    notes TEXT
);

CREATE TABLE certifications (
    id SERIAL PRIMARY KEY,
    producer_id INT REFERENCES producers(id) ON DELETE CASCADE,
    scheme TEXT NOT NULL, -- BIO, FAIRTRADE, etc.
    status TEXT NOT NULL,
    valid_from DATE,
    valid_to DATE
);

-- Deforestation/EUDR checks
CREATE TABLE deforestation_checks (
    id SERIAL PRIMARY KEY,
    parcel_id INT REFERENCES parcels(id) ON DELETE CASCADE,
    status TEXT NOT NULL, -- ok, risk, unknown
    polygon_geojson JSONB,
    result_json JSONB,
    checked_at TIMESTAMP DEFAULT NOW()
);

-- Marketplace
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    unit TEXT DEFAULT 'kg'
);

CREATE TABLE offers (
    id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(id) ON DELETE CASCADE,
    coop_id INT REFERENCES coops(id) ON DELETE CASCADE,
    incoterm TEXT,
    quantity_mt NUMERIC,
    price_usd_mt NUMERIC,
    valid_until DATE
);

-- Users & documents
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    role TEXT CHECK (role IN ('admin','manager','inspector','viewer')),
    password_hash TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE documents (
    id SERIAL PRIMARY KEY,
    producer_id INT REFERENCES producers(id) ON DELETE SET NULL,
    doc_type TEXT,
    url TEXT,
    uploaded_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE audit_logs (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id),
    action TEXT,
    details JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Views
CREATE OR REPLACE VIEW view_producer_summary AS
SELECT p.id as producer_id, p.name, COUNT(par.id) as parcelles_count,
       SUM(h.dry_kg) as total_dry_kg,
       MAX(c.valid_to) as cert_valid_to
FROM producers p
LEFT JOIN parcels par ON par.producer_id=p.id
LEFT JOIN harvest_lots h ON h.parcel_id=par.id
LEFT JOIN certifications c ON c.producer_id=p.id
GROUP BY p.id, p.name;

-- Seed data
INSERT INTO coops (name, region, contact)
VALUES ('VASA Coop', 'Diana-Ambanja', '+261320000000');

INSERT INTO producers (coop_id, name, region, contact)
VALUES (1, 'Jean Ranaivo', 'Ambanja', '+261330000111');

INSERT INTO parcels (producer_id, name, crop, lat, lng, area_ha)
VALUES (1, 'Parcelle A', 'cacao', -13.682, 48.455, 1.5);

INSERT INTO products (name, description, unit)
VALUES ('Cacao beans', 'High quality Sambirano cacao', 'kg');
