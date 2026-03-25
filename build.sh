#!/usr/bin/env bash
# Render build script — run during deploy
set -e

echo "==> Installing Python dependencies..."
pip install -r requirements.txt

echo "==> Setting up PostgreSQL database..."
if [ -n "$DATABASE_URL" ]; then
    echo "  Running schema..."
    psql "$DATABASE_URL" -f database/schema_postgres.sql

    # Only seed if the moods table is empty (first deploy)
    ROW_COUNT=$(psql "$DATABASE_URL" -t -c "SELECT COUNT(*) FROM Moods;" 2>/dev/null || echo "0")
    ROW_COUNT=$(echo "$ROW_COUNT" | xargs)  # trim whitespace
    if [ "$ROW_COUNT" = "0" ]; then
        echo "  Seeding data..."
        psql "$DATABASE_URL" -f database/seed_postgres.sql
    else
        echo "  Data already seeded, skipping."
    fi
else
    echo "  WARNING: DATABASE_URL not set, skipping DB setup."
fi

echo "==> Build complete!"
