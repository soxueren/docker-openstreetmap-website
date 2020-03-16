-- Extension: btree_gist
DROP EXTENSION btree_gist CASCADE;
CREATE EXTENSION btree_gist
    SCHEMA public;

-- Extension: hstore
DROP EXTENSION hstore CASCADE;
CREATE EXTENSION hstore
    SCHEMA public;


-- Extension: postgis
DROP EXTENSION postgis CASCADE;
CREATE EXTENSION postgis 
    SCHEMA public;
