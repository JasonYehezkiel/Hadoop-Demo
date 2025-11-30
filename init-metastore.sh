#!/bin/bash
set -e

echo "=== Waiting for PostgreSQL ==="
until nc -z hive-metastore-postgresql 5432; do
  echo "PostgreSQL is unavailable - sleeping"
  sleep 5
done

echo "=== PostgreSQL is ready ==="
sleep 10  # Additional wait for PostgreSQL to fully initialize

echo "=== Checking if schema exists ==="
if /opt/hive/bin/schematool -dbType postgres -info 2>&1 | grep -q "Metastore schema version"; then
  echo "=== Schema already exists, skipping initialization ==="
else
  echo "=== Initializing Hive Metastore Schema ==="
  /opt/hive/bin/schematool -dbType postgres -initSchema
fi

echo "=== Done ==="