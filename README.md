# init database 
```
docker run --rm -e PG_HOST=localhost -e PGPASSWORD=xxxxxx -e PGDATABASE=osm soxueren/osm-website:pg
```
# import pbf
```
 osmosis --read-pbf xxx.osm.pbf --used-node --write-apidb host="localhost" database="osm"  user="postgres" password="xxxxxxx" validateSchemaVersion="no"
```
#  start osm-web site
```
docker run -it -d --name osm-web -e PG_HOST=localhost -e PGDATABASE=osm -e POSTGRES_PASSWORD=xxxxxx -p 3000:3000 soxueren/osm-website:srv bundle exec rails server -b 0.0.0.0
```
# get auth key for editor
```
docker cp settings.local.yml osm-web:/openstreetmap-website/config/settings.local.yml
```
