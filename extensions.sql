-- Extension: btree_gist

DROP EXTENSION btree_gist;
CREATE EXTENSION btree_gist
    SCHEMA public
    VERSION "1.2";

-- Extension: hstore

DROP EXTENSION hstore;
CREATE EXTENSION hstore
    SCHEMA public
    VERSION "1.4";

-- Extension: postgis

DROP EXTENSION postgis;
CREATE EXTENSION postgis
    SCHEMA public
    VERSION "2.5.1";

