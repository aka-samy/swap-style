# Alternative Setup Guide (Without Docker)

If Docker and WSL2 are not available, follow this guide to set up locally.

---

## Prerequisites

- Node.js 18+ (already have npm working)
- PostgreSQL 16.x local installation
- Redis 7+ (optional, can mock in tests)
- Dart/Flutter SDK (already installed)

---

## Step 1: Install PostgreSQL Locally (Windows)

### Option A: Download Installer (Recommended for Windows)

1. Visit https://www.postgresql.org/download/windows/
2. Download PostgreSQL 16 windows installer
3. Run installer:
   - **Installation Directory**: `C:\Program Files\PostgreSQL\16`
   - **Port**: Keep default `5432`
   - **Username**: `postgres`
   - **Password**: `postgres` (to match .env file)
   - **Locale**: Default
   - **Initialize Database Cluster**: Yes
4. Finish installation (creates Windows Service)
5. Test connection:
```bash
"C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -c "SELECT 1;"
```

### Option B: PostgreSQL Portable (if installer fails)

1. Download portable version from https://www.enterprisedb.com/download-postgresql-binaries
2. Extract to `C:\PostgreSQL`
3. Ensure it runs on startup

---

## Step 2: Create Database

```powershell
# Via psql
"C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -c "CREATE DATABASE swapstyle WITH ENCODING 'UTF8';"

# Verify
"C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -d swapstyle -c "SELECT 1;"
```

If psql command doesn't work, try the full path or use pgAdmin (GUI).

---

## Step 3: Install PostGIS Extension (For Location Queries)

```powershell
"C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -d swapstyle -c "CREATE EXTENSION postgis;"
```

Verify:
```bash
"C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -d swapstyle -c "SELECT PostGIS_version();"
```

---

## Step 4: Verify .env Configuration

File: `api/.env`
```
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/swapstyle?schema=public
REDIS_HOST=localhost
REDIS_PORT=6379
```

If PostgreSQL is on **different port** or **different user**, update DATABASE_URL accordingly.

---

## Step 5: Run Prisma Migrations

```powershell
cd C:\swapstyle\api

# Run migrations
npx prisma migrate dev --name init

# You'll be prompted:
# - Create migration? → Yes
# - Migration name → Type "init" and press Enter

# This creates:
# - prisma/migrations/timestamp_init/migration.sql
# - Creates all tables in PostgreSQL
```

Expected output:
```
✔ Generated Prisma Client (X.X.X in Xs)
✔ Migrated successfully to timestamp_init (XXms)
✔ Migration created in prisma/migrations/timestamp_init
```

---

## Step 6: Seed Database (Optional)

Run sample data loader:

```powershell
cd C:\swapstyle\api
npx prisma db seed
```

This populates the database with demo users, items, and matches.

---

## Step 7: Set Up Redis (Optional but Recommended)

### Option A: Windows Redis Native (Memurai)

```powershell
# Install Redis for Windows
winget install Memurai.Memurai
```

If winget fails:
1. Visit https://github.com/microsoftarchive/redis/releases
2. Download latest `Redis-x64-*.msi`
3. Run installer (default port 6379)
4. Test: `redis-cli ping` → Should respond `PONG`

### Option B: Skip Redis (Tests Mock It)

Redis is optional. Tests use mocks. Leave `REDIS_HOST=localhost` in `.env`.

---

## Step 8: Start Backend Server

```powershell
cd C:\swapstyle\api

# Development mode with auto-reload
npm run start:dev

# Should see:
# ✓ NestJS application successfully started
# ✓ Listening on port 3000
# ✓ Swagger available at http://localhost:3000/api
```

Visit: http://localhost:3000/api (Swagger UI)

---

## Step 9: Complete Flutter Setup

Once pub get finishes (on macOS/Linux/WSL2):

```bash
cd mobile/
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run  # or select emulator first
```

---

## Troubleshooting

### PostgreSQL Connection Refused
```
Error: ECONNREFUSED 127.0.0.1:5432
```
**Fix**: 
1. Ensure PostgreSQL service is running
   ```powershell
   Get-Service "postgresql*" | Select-Object Status,Name
   ```
2. Restart if needed:
   ```powershell
   Restart-Service "postgresql-x64-16"
   ```
3. Verify credentials in .env match installation

### Migration Failed
```
Error: Client generation failed
```
**Fix**:
1. Delete `node_modules/.prisma`
2. Regenerate:
   ```bash
   npx prisma generate
   ```
3. Retry migration:
   ```bash
   npx prisma migrate dev --name init
   ```

### Port Already in Use
```
Error: EADDRINUSE :::3000
```
**Fix**:
```powershell
# Find process on port 3000
netstat -ano | findstr :3000

# Kill it
taskkill /PID <PID> /F
```

Or change port in `api/.env`:
```
PORT=3001
```

---

## Verification Checklist

- [ ] PostgreSQL running (`psql -U postgres -d swapstyle -c "SELECT 1;"`)
- [ ] Database created (`\l` in psql shows "swapstyle")
- [ ] PostGIS installed (`SELECT postgis_version();`)
- [ ] Migrations applied (`npx prisma migrate status` shows all applied)
- [ ] Node server running on http://localhost:3000
- [ ] Swagger docs accessible
- [ ] npm tests pass (`npm test` → 69/69)
- [ ] Redis running (if using) (`redis-cli ping` → PONG)

---

## Next: Frontend Setup

Once backend is running and tested:

```bash
cd mobile/
flutter run
# Select emulator or physical device
```

The app will connect to `http://localhost:3000` (or configure in `mobile/lib/core/api/api_client.dart`).
