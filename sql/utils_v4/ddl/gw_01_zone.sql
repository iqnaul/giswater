/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


-- ----------------------------
-- Table: GIS features
-- ----------------------------

CREATE TABLE macroexploitation(
id integer NOT NULL PRIMARY KEY,
value character varying(50) ,
descript text,
is_undelete boolean
);


CREATE TABLE exploitation(
id integer  NOT NULL PRIMARY KEY,
value character varying(50),
descript text,
macroexploitation_id integer,
is_undelete boolean,
the_geom geometry(MULTIPOLYGON,SRID_VALUE),
tstamp timestamp DEFAULT now()
);


CREATE TABLE macrodma(
id serial NOT NULL PRIMARY KEY,
value character varying(50),
descript text,
exploitation_id integer,
is_undelete boolean,
the_geom geometry(MULTIPOLYGON,SRID_VALUE)
);


CREATE TABLE dma (
id serial NOT NULL PRIMARY KEY,
value character varying(30),
descript text,
exploitation_id integer,
macrodma_id integer,
is_undelete boolean,
the_geom public.geometry (MULTIPOLYGON, SRID_VALUE)
);


CREATE TABLE macrosector (
id serial NOT NULL PRIMARY KEY,
value character varying(50),
descript text,
is_undelete boolean,
the_geom geometry (MULTIPOLYGON, SRID_VALUE)
);


CREATE TABLE sector (
id serial NOT NULL PRIMARY KEY,
value character varying(50),
descript text,
macrosector_id integer,
is_undelete boolean,
the_geom public.geometry (MULTIPOLYGON, SRID_VALUE)
);




