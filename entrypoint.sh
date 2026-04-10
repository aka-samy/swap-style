#!/bin/sh
set -e

echo "=== Container starting ==="
echo "NODE_ENV: $NODE_ENV"
echo "PORT: $PORT"
if [ -z "$DATABASE_URL" ]; then
  if [ -n "$DATABASE_PRIVATE_URL" ]; then
    export DATABASE_URL="$DATABASE_PRIVATE_URL"
  elif [ -n "$DATABASE_PUBLIC_URL" ]; then
    export DATABASE_URL="$DATABASE_PUBLIC_URL"
  elif [ -n "$POSTGRES_URL" ]; then
    export DATABASE_URL="$POSTGRES_URL"
  fi
elif echo "$DATABASE_URL" | grep -Eq 'localhost|127\.0\.0\.1'; then
  echo "WARNING: DATABASE_URL points to localhost. Trying Railway DB aliases..."
  if [ -n "$DATABASE_PRIVATE_URL" ]; then
    export DATABASE_URL="$DATABASE_PRIVATE_URL"
    echo "Switched DATABASE_URL to DATABASE_PRIVATE_URL"
  elif [ -n "$DATABASE_PUBLIC_URL" ]; then
    export DATABASE_URL="$DATABASE_PUBLIC_URL"
    echo "Switched DATABASE_URL to DATABASE_PUBLIC_URL"
  elif [ -n "$POSTGRES_URL" ]; then
    export DATABASE_URL="$POSTGRES_URL"
    echo "Switched DATABASE_URL to POSTGRES_URL"
  fi
fi
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
exec node dist/src/main.js
