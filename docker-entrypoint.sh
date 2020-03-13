#!/bin/bash
set -e 

cd /openstreetmap-website && bundle exec rake db:create

psql -d osm -h $PGHOST -p $PGPORT --username $PGUSER -f /openstreetmap-website/db/extensions.sql

psql -d osm -h $PGHOST -p $PGPORT --username $PGUSER -f /openstreetmap-website/db/functions/functions.sql

cd /openstreetmap-website  && bundle exec rake db:migrate && bundle exec rake test:db

exec "$@"
