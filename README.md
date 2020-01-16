# import pbf
```
 osmosis --read-pbf xxx.osm.pbf --write-apidb host="localhost" database="osm"  user="postgres" password="123456" validateSchemaVersion="no"
```
#  start osm-web site
```
docker run -it -d --name osm-web -p 3000:3000 osm-server:latest bundle exec rails server -b 0.0.0.0
```
# get auth key for editor
```
docker cp settings.local.yml osm-web:/openstreetmap-website/config/settings.local.yml
```
