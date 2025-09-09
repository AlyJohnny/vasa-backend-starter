# VASA Backend Starter (Express + PostgreSQL)

## 1) Local setup
- Copy `.env.example` to `.env` and fill `DATABASE_URL` (Railway private URL if running on Railway).
- Install deps: `npm install`
- Initialize DB tables: `npm run init:db`
- Start: `npm run dev`

## 2) Railway deploy
- Create Postgres plugin in your Railway project.
- Add a new service -> Deploy from GitHub or Upload this folder.
- In Variables, set:
  - `PORT=5000`
  - `DATABASE_URL` = use `${{ URL_BASE_DE_DONNÉES }}` (private) when API and DB are in the same Railway project
  - `API_KEY=Vasa2025SecretKey`
- Run once: `npm run init:db` (via Railway shell) to create the `producers` table.

## 3) Test endpoints
- `GET /api/health` -> check DB connection
- `GET /api/producers`
- `POST /api/producers` with JSON body: `{ "name":"Jean", "region":"SAVA", "contact":"+261..." }`
