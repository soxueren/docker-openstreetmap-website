# Docker镜像

## 基础osm-website镜像:Dockerfile-base

```
FROM ubuntu:latest

RUN apt-get update

ENV LANGUAGE en_US.UTF-8 
ENV LANG en_US.UTF-8 
ENV LC_ALL en_US.UTF-8

RUN DEBIAN_FRONTEND=noninteractive apt install -y tzdata

RUN apt-get install -y ruby2.5 libruby2.5 ruby2.5-dev bundler \
                     libmagickwand-dev libxml2-dev libxslt1-dev nodejs \
                     apache2 apache2-dev build-essential git-core phantomjs \
                     libsasl2-dev libpq-dev postgresql-contrib postgresql-server-dev-all \
                     imagemagick libffi-dev libgd-dev libarchive-dev libbz2-dev
					 
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update && apt-get install -y yarn

RUN apt-get remove -y bundler

RUN gem2.5 install rdoc && \
        gem2.5 rdoc --all --overwrite
	
RUN gem2.5 install bundler && gem2.5 pristine bundler

RUN gem2.5 install nokogiri -v '1.10.7' && \
	 gem2.5 install nio4r -v '2.5.2' && \
	 gem2.5 install websocket-driver -v '0.7.1' && \
	 gem2.5 install html_tokenizer -v '0.0.7' && \
	 gem2.5 install debug_inspector -v '0.0.3' && \
	 gem2.5 install binding_of_caller -v '0.8.0' && \
	 gem2.5 install msgpack -v '1.3.1' && \
	 gem2.5 install bootsnap -v '1.4.5' && \
	 gem2.5 install ffi -v '1.11.3' && \
	 gem2.5 install sassc -v '2.2.1' && \
	 gem2.5 install json -v '2.3.0' && \
	 gem2.5 install jaro_winkler -v '1.5.4' && \
	 gem2.5 install kgio -v '2.11.2' && \
	 gem2.5 install libxml-ruby -v '3.1.0'  && \	 
	 gem2.5 install nokogumbo -v '2.0.2'  && \
	 gem2.5 install pg -v '1.2.1' && \
	 gem2.5 install puma -v '3.12.2' && \
	 gem2.5 install quad_tile -v '1.0.1' && \
	 gem2.5 install rinku -v '2.0.6' 
	 
RUN git clone --depth=1 https://github.com/soxueren/openstreetmap-website.git

RUN cd openstreetmap-website && bundle install  && \
        bundle exec rake yarn:install
	
RUN locale-gen en_US.UTF-8

RUN apt-get clean

CMD ["bash"]
```

## 数据库初始化镜像:Dockerfile-pg
```
FROM soxueren/osm-website:base

RUN cd /openstreetmap-website/db/functions && \
        make libpgosm.so && \
        cd ../..

ENV PGDATABASE osm
ENV PGPASSWORD 123456
ENV POSTGRES_USER postgres
ENV PG_HOST 10.0.4.5

ADD postgresql/database.yml /openstreetmap-website/config/database.yml

ADD extensions.sql /openstreetmap-website/db/extensions.sql

ADD docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["bash","/docker-entrypoint.sh"]

CMD ["bash"]
```
docker-entrypoint.sh
```
#!/bin/bash
set -e 

cd /openstreetmap-website && bundle exec rake db:create

psql -d osm -h $PG_HOST --username $POSTGRES_USER -f /openstreetmap-website/db/extensions.sql

psql -d osm -h $PG_HOST --username $POSTGRES_USER -f /openstreetmap-website/db/functions/functions.sql

cd /openstreetmap-website  && bundle exec rake db:migrate && bundle exec rake test:db

exec "$@"
```
database.yml
```
# Using a recent release (9.1 or higher) of PostgreSQL (http://postgresql.org/) is recommended.
# See https://github.com/openstreetmap/openstreetmap-website/blob/master/INSTALL.md#database-setup for detailed setup instructions.
#
development: &default
  adapter: postgresql
  database: <%= ENV["PGDATABASE"] || 'osm' %>
  username: <%= ENV["POSTGRES_USER"] || 'postgres' %>
  password: <%= ENV["PGPASSWORD"] || '123456' %>
  host: <%= ENV["PG_HOST"] || 'localhost' %>
  encoding: utf8

# Warning: The database defined as 'test' will be erased and
# re-generated from your development database when you run 'rake'.
# Do not set this db to the same as development or production.
test:
  <<: *default

production:
  <<: *default
```
## 网页服务osm-website镜像:Dockerfile-srv

```
FROM soxueren/osm-website:base

ENV PGDATABASE osm
ENV PGPASSWORD 123456
ENV POSTGRES_USER postgres
ENV PG_HOST 10.0.4.5

RUN apt-get update 

RUN cd /openstreetmap-website/db/functions && \
        make libpgosm.so && \
        cd ../..
		
RUN apt-get install -y pngcrush optipng pngquant jhead jpegoptim gifsicle

RUN apt-get clean

ADD postgresql/database.yml /openstreetmap-website/config/database.yml

RUN touch /openstreetmap-website/config/settings.local.yml
	
RUN cp /openstreetmap-website/config/example.storage.yml /openstreetmap-website/config/storage.yml

WORKDIR /openstreetmap-website

EXPOSE 3000

CMD ["bash"]
```

# 初始化数据库并准备数据

## 创建postgis数据库

```
docker run --name osm-postgis -it -d -e PG_HOST=192.168.199.177 -e PGDATABASE=osm -e POSTGRES_PASSWORD=123456 -p 5432:5432 -v /data/osm-postgis:/var/lib/postgresql/data -d mdillon/postgis:9.5-alpine
```

## 准备数据

####  裁剪数据
```
osmosis --read-pbf .\china-latest.osm.pbf --bounding-box top=49.28 left=73.48 bottom=35.10 right=96.68 --write-xml xj.osm
```
#### josm修复xj.osm错误数据
```
全选->验证->修复->保存
```
#### osm->pbf可供graphhopper使用
```
osmosis --read-xml xj.osm --write-pbf xj.osm.pbf
```
- [数据格式转换参数](https://wiki.openstreetmap.org/wiki/Osmosis/Detailed_Usage_0.47#--used-node_.28--un.29):
--read-pbf --write-xml --read-xml --write-pbf

### 初始化osm数据库

#### 1 创建osm数据库

#### 2 创建postgis、hstore、btree_gist扩展

- extensions.sql

```
-- Extension: btree_gist

-- DROP EXTENSION btree_gist;

CREATE EXTENSION btree_gist
    SCHEMA public
    VERSION "1.2";

-- Extension: hstore

-- DROP EXTENSION hstore;

CREATE EXTENSION hstore
    SCHEMA public
    VERSION "1.4";

-- Extension: postgis

-- DROP EXTENSION postgis;

CREATE EXTENSION postgis
    SCHEMA public
    VERSION "2.5.1";
```
#### 3 初始化表结构
```
#运行容器初始化数据库
docker run --rm -e PG_HOST=192.168.199.177 -e PGPASSWORD=123456 -e PGDATABASE=osm soxueren/osm-website:pg
#用osmosis/script的sql文件初始化数据库，存在libpgosm.so问题，所以建议使用容器初始化osm数据库
```

* 使用--write-pgsimp 对应 osmosis/script/pgsimple_schema_0.6.sql
* 使用--write-apidb 对应 osmosis/script/contrib/apidb_0.6.sql

无容器环境情况下使用 --write-apidb 初始化使用的apidb_0.6.sql样例

#### 4 创建几何字段和索引

- idx_geom_osm.sql

```
-- Add a postgis point column holding the location of the node.
SELECT AddGeometryColumn('nodes', 'geom', 4326, 'POINT', 2);

-- Add indexes to tables.
CREATE INDEX idx_node_tags_node_id ON node_tags USING btree (node_id);
CREATE INDEX idx_nodes_geom ON nodes USING gist (geom);

CREATE INDEX idx_way_tags_way_id ON way_tags USING btree (way_id);
CREATE INDEX idx_way_nodes_node_id ON way_nodes USING btree (node_id);

CREATE INDEX idx_relation_tags_relation_id ON relation_tags USING btree (relation_id);

-- Add a postgis GEOMETRY column to the way table for the purpose of storing the full linestring of the way.
SELECT AddGeometryColumn('ways', 'linestring', 4326, 'GEOMETRY', 2);

-- Add an index to the bbox column.
CREATE INDEX idx_ways_linestring ON ways USING gist (linestring);

-- Add a postgis GEOMETRY column to the way table for the purpose of indexing the location of the way.
-- This will contain a bounding box surrounding the extremities of the way.
SELECT AddGeometryColumn('ways', 'bbox', 4326, 'GEOMETRY', 2);

-- Add an index to the bbox column.
CREATE INDEX idx_ways_bbox ON ways USING gist (bbox);

-- Add column nearby to the users table
ALTER TABLE public.users
    ADD COLUMN nearby integer DEFAULT 50;
    
-- 解决current_way_nodes表的数据不一致bug    
-- Drop current_way_nodes_node_id_fkey   
ALTER TABLE public.current_way_nodes
 DROP CONSTRAINT current_way_nodes_node_id_fkey

-- ALTER TABLE public.current_way_nodes
--     ADD CONSTRAINT current_way_nodes_node_id_fkey FOREIGN KEY (node_id)
--     REFERENCES public.current_nodes (id) MATCH SIMPLE
--     ON UPDATE NO ACTION
--     ON DELETE NO ACTION;

```
#### 5 导入数据导数据库
```
osmosis --read-xml xj.osm --used-node --write-apidb host="localhost" database="osm"  user="postgres" password="123456" validateSchemaVersion="no"  populateCurrentTables="yes"
```
* ==--used-node ->Restricts output of nodes to those that are used in ways and relations将节点的输出限制为在方式和关系中使用的节点==
* ==表users增加nearby列:ALTER TABLE public.users ADD COLUMN nearby integer DEFAULT 50==
* ==validateSchemaVersion="no" 跳过版本检测防止出错==
* ==当前表current_* 出错请删除相关外键==
* 导入数据是会有user_id=-1的bug后续会处理

#  start osm-web site
```
docker run -it -d --name osm-web -e PG_HOST=192.168.199.177 -e PGDATABASE=osm -e POSTGRES_PASSWORD=123456 -p 3000:3000 soxueren/osm-website:srv bundle exec rails server -b 0.0.0.0
```
## get auth key for editor

* ==mysetting->auth设置->注册应用->获取激活码填写settings.local.yml==

settings.local.yml
```
# Default editor
default_editor: "id"
# OAuth consumer key for Potlatch 2
potlatch2_key: "91sj9mZ4mLQUODngBtMHWR7xjhfXV3AZLTBz9mJ4"
# OAuth consumer key for the web site
#oauth_key: ""
# OAuth consumer key for iD
id_key: "xakpsuIMUwSVgCBG1WZ6iuL4jAGZHLA1Jns2lX0d"

# The maximum area you're allowed to request, in square degrees
max_request_area: 5
# Number of GPS trace/trackpoints returned per-page
tracepoints_per_page: 10000
# Maximum number of nodes that will be returned by the api in a map request
max_number_of_nodes: 100000
# Maximum number of nodes that can be in a way (checked on save)
max_number_of_way_nodes: 10000
# The maximum area you're allowed to request notes from, in square degrees
max_note_request_area: 50
```
* 参数与导出osm文件有关的max_request_area、max_number_of_nodes、max_number_of_way_nodes、max_note_request_area

```
docker cp settings.local.yml osm-web:/openstreetmap-website/config/settings.local.yml
```
* 用户激活sql

```
-- 激活用户
UPDATE users set status='active'
```
* 解决osmosis导入数据后changesets表user_id=-1的bug问题
```
ALTER TABLE public.changesets
    DROP CONSTRAINT changesets_user_id_fkey;
    
-- osmosis导入数据出现user_id=-1的问题

UPDATE changesets set user_id=0 where user_id=-1;
UPDATE users set id=0 where id=-1;

ALTER TABLE public.changesets
    ADD CONSTRAINT changesets_user_id_fkey FOREIGN KEY (user_id)
    REFERENCES public.users (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;
```

pg_hba.conf
```
host    all            all             10.0.4.5/32               trust
host    all            all             192.168.199.177/32          trust
```
