/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

-- ----------------------------
-- Base map
-- ----------------------------

-- Municipality
CREATE TABLE ext_municipality (
id integer PRIMARY KEY,
value varchar(50),
descript text,
the_geom geometry(MULTIPOLYGON, SRID_VALUE)
);



-- Streeter
CREATE TABLE ext_type_street (
id integer PRIMARY KEY NOT NULL,
value varchar(50),
descript text
);



CREATE TABLE ext_streetaxis (
id integer PRIMARY KEY NOT NULL,
code varchar (16),
ext_type_street_id varchar(18),
value varchar(100),
descript text,
exploitation_id integer,
ext_municipality_id integer,
the_geom public.geometry (LINESTRING, SRID_VALUE)
);



-- Postnumber
CREATE TABLE ext_address(
id integer PRIMARY KEY NOT NULL,
ext_municipality_id integer,
postcode character varying(16),
ext_streetaxis_id character varying(16),
postnumber character varying(16),
ext_plot_id character varying(16),
exploitation_id integer,
the_geom geometry(Point,SRID_VALUE)
  );

  

-- Urban_structure
CREATE TABLE ext_plot(
id integer PRIMARY KEY NOT NULL,
code varchar(30),
ext_municipality_id integer,
postcode  varchar(16),
ext_streetaxis_id varchar(16),
postnumber varchar(16),
complement varchar(16),
placement varchar(16),
square varchar(16),
observ text,
descript text,
the_geom public.geometry (MULTIPOLYGON, SRID_VALUE),
exploitation_id integer
);
