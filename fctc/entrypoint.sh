#!/bin/bash
set -euo pipefail

echo "Waiting for database at ${DATABASE_HOST:-postgres}..."
until pg_isready -h "${DATABASE_HOST:-postgres}" -U "${DATABASE_USERNAME:-postgres}" -q; do
  sleep 1
done

bin/rails db:create db:migrate
bin/rails assets:precompile
bin/rails db:seed

exec "$@"
