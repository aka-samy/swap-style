#!/bin/sh
set -e

echo "=== Container starting ==="
echo "NODE_ENV: $NODE_ENV"
echo "PORT: $PORT"
echo "DATABASE_URL is set: $([ -n "$DATABASE_URL" ] && echo 'YES' || echo 'NO')"
echo "REDIS_HOST: $REDIS_HOST"
echo "==========================="

if [ -z "$DATABASE_URL" ]; then
  echo "ERROR: DATABASE_URL environment variable is not set!"
  echo "Please set DATABASE_URL in your Railway service variables."
  exit 1
fi

echo "Running prisma migrate deploy..."
npx prisma migrate deploy

echo "Starting application..."
exec node dist/main.js
