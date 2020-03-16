# init database 
```
docker run --rm -e PGHOST=localhost -e PGPASSWORD=xxxxxx -e PGDATABASE=osm soxueren/osm-website:pg
```
## 导入数据前需要处理的问题

###  current_way_nodes 外键导致导入出错问题
```
-- nearby字段新版缺失问题
-- Add column nearby to the users table
ALTER TABLE public.users
    ADD COLUMN nearby integer DEFAULT 50;
    
-- 解决current_way_nodes表的数据不一致bug    
-- Drop current_way_nodes_node_id_fkey   
ALTER TABLE public.current_way_nodes
 DROP CONSTRAINT current_way_nodes_node_id_fkey
```

# import pbf
```
 osmosis --read-pbf xxx.osm.pbf --used-node --write-apidb host="localhost" database="osm"  user="postgres" password="xxxxxxx" validateSchemaVersion="no"
```
## 导入数据后需要处理的问题

###  osmosis导入数据后出现osmosis账号的user_id=-1的问题
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
#  start osm-web site
```
docker run -it -d --name osm-web -e PGHOST=localhost -e PGDATABASE=osm -e PGPASSWORD=xxxxxx -p 3000:3000 soxueren/osm-website:srv bundle exec rails server -b 0.0.0.0
```
# get auth key for editor
```
docker cp settings.local.yml osm-web:/openstreetmap-website/config/settings.local.yml
```
