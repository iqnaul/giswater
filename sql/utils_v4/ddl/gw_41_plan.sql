/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

SET search_path = SCHEMA_NAME, public, pg_catalog;

---------------------------------------------------------------
-- COMMON SQL (WS & UD)
---------------------------------------------------------------

-- ----------------------------
-- Sequence structure
-- ----------------------------

  
CREATE SEQUENCE price_simple_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
	
	
CREATE SEQUENCE price_compost_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
	

CREATE SEQUENCE price_simple_value_seq
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;

  

----------------------------------------------
-- TABLE STRUCTURE FOR PLAN
---------------------------------------------

CREATE TABLE plan_psector (
id integer NOT NULL PRIMARY KEY,
value varchar (50),
plan_psector_cat_type_id integer,
descript text ,
exploitation_id integer,
priority varchar(16) ,
text1 text ,
text2 text ,
observ text ,
rotation numeric (8,4),
scale numeric (8,2),
sector_id integer,
atlas_id varchar(16) ,
gexpenses numeric (4,2),
vat numeric (4,2),
other numeric (4,2),
is_active boolean,
the_geom public.geometry (MULTIPOLYGON, SRID_VALUE)
);


CREATE TABLE plan_psector_x_inv (
id serial NOT NULL PRIMARY KEY,
inv_id varchar(16) ,
plan_psector_id integer, 
sys_cat_stateinteger,
is_doable boolean,
descript text
);



CREATE TABLE plan_psector_x_other (
id serial NOT NULL PRIMARY KEY,
price_id varchar(16) ,
measurement numeric (12,2),
plan_psector_id integer,
descript text
);


CREATE TABLE plan_arc_x_pavement (
id serial NOT NULL PRIMARY KEY,
arc_id character varying(16),
pavcat_id character varying(16),
percent numeric (3,2)
);


CREATE TABLE plan_psector_cat_type (
id integer  NOT NULL PRIMARY KEY,
value varchar(50),
descript text 
);


CREATE TABLE plan_psector_selector(
  id serial NOT NULL PRIMARY KEY,
  plan_psector_id integer NOT NULL,
  user_name text NOT NULL
);


----------------------------------------------
-- TABLE SCTRUCTURE FOR PRICE
---------------------------------------------

CREATE TABLE price_cat_simple (
id integer  PRIMARY KEY NOT NULL,
value varchar (50),
descript text,
tstamp timestamp default now(),
user_name text
);


CREATE TABLE audit_price_simple (
  id integer PRIMARY KEY NOT NULL,
  value varchar(50),
  price_cat_simple_id integer,
  price_value_unit_id integer,
  descript text,
  price numeric(12,4),
  observ character varying(16),
  tstamp timestamp default now(),
  user_name text
);


CREATE TABLE price_simple (
  id integer  PRIMARY KEY NOT NULL,
  value character varying(50),
  price_cat_simple_id integer,
  price_value_unit_id integer,
  descript character varying(100),
  text text,
  price numeric(12,4),
  observ character varying(16)
);


CREATE TABLE price_compost (
  id integer PRIMARY KEY NOT NULL,
  value varchar(50),
  price_value_unit_id integer,
  descript text,
  price numeric(12,4)
);


CREATE TABLE price_compost_value (
  id serial PRIMARY KEY NOT NULL,
  price_compost_id integer,
  price_simple_id integer,
  value numeric (16,4)
);


CREATE TABLE price_value_unit (
  id integer PRIMARY KEY,
  value character varying(50),
  descript text
);



CREATE TABLE plan_result_selector (
id serial PRIMARY KEY,
om_result_cat_id integer,
user_name text
);



CREATE TABLE plan_result_type (
id integer  NOT NULL PRIMARY KEY,
value varchar(50),
descript text 
);
