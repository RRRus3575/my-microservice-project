#!/usr/bin/env bash
set -e

# Wait for Postgres
python - <<'PY'
import os, time, socket
host = os.getenv("DB_HOST", "db")
port = int(os.getenv("DB_PORT", "5432"))
for i in range(60):
    try:
        with socket.create_connection((host, port), timeout=1):
            print("Postgres is up!")
            break
    except OSError:
        print("Waiting for Postgres...")
        time.sleep(1)
else:
    raise SystemExit("Postgres did not become available in time.")
PY

python manage.py migrate --noinput
# Optional: collectstatic (safe if no static configured)
python manage.py collectstatic --noinput || true

# Start the app with Gunicorn
exec gunicorn config.wsgi:application --bind 0.0.0.0:8000 --workers 2 --threads 4 --timeout 120
