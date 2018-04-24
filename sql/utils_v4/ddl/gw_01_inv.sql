/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = "SCHEMA_NAME", public, pg_catalog;


CREATE SEQUENCE urn_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------
-- Table: GIS features
-- ----------------------------

CREATE TABLE inv_cat_systable(
"id" serial PRIMARY KEY DEFAULT nextval('SCHEMA_NAME.urn_id_seq'::regclass),
"value" varchar(50),
"class_id" integer,
"is_addfields" boolean,
"is_codeautofill" boolean,
"is_main" boolean,
"numarcs" integer,
"is_nodearc" boolean,
"epavdef_id" integer,
"orderby" integer,
"shortcut" varchar(3),
"linkpath" varchar(250),
"descript" text,
"is_active" boolean
);


CREATE TABLE inv (
"inv_id" integer PRIMARY KEY,
"code" varchar (30),
"inv_cat_systype_id" integer,
"sys_cat_state_id" integer,
"sys_cat_statetype_id" integer,
"cat_work_id" integer,
"cat_work_id_end" integer,
"builtdate" date,
"enddate" date,
"link" character varying(512),
"parent_id" integer,
"annotation" text,
"observ" text,
"is_undelete" boolean,
"is_publish" boolean,
"cat_verified_id" varchar(30),
"tstamp" timestamp DEFAULT now()
);



CREATE TABLE "node" (
"inv_id" integer PRIMARY KEY,
"top_elev" numeric(12,4),
"ymax" numeric(12,4),
"exploitation_id" integer,
"dma_id" integer,
"sector_id" integer,
"cat_fluid_id" integer,
"cat_category_id" integer,
"cat_soil_id" integer,
"muni_id" integer ,
"postcode"  varchar(16) ,
"streetaxis_id" varchar(16)  ,
"postnumber" integer,
"postcomplement" varchar (16),
"streetaxis2_id" varchar(16)  ,
"postnumber2" integer,
"postcomplement2" varchar (16),
"rotation" numeric (6,3),
"hemisphere" float,
"label_x" character varying(30),
"label_y" character varying(30),
"label_rotation" numeric(6,3),
"the_geom" public.geometry (POINT, SRID_VALUE)
);



CREATE TABLE "arc" (
"inv_id" integer PRIMARY KEY,
"node_1" varchar(16), 
"node_2" varchar(16), 
"epatype_id" varchar(16),
"y1" numeric(12,2),
"y2" numeric(12,2),
"exploitation_id" integer,
"dma_id" integer,
"sector_id" integer,
"cat_fluid_id" integer,
"cat_category_id" integer,
"cat_soil_id" integer,
"muni_id" integer ,
"postcode"  varchar(16) ,
"streetaxis_id" varchar(16)  ,
"postnumber" integer,
"postcomplement" varchar (16),
"streetaxis2_id" varchar(16)  ,
"postnumber2" integer,
"postcomplement2" varchar (16),
"label_x" character varying(30),
"label_y" character varying(30),
"label_rotation" numeric(6,3),
"the_geom" public.geometry (POINT, SRID_VALUE)
);



CREATE TABLE "link" (
"id" integer PRIMARY KEY,
"inv_id" integer,
"exit_node" integer,
"sys_cat_state_id" integer);
"label_x" character varying(30),
"label_y" character varying(30),
"label_rotation" numeric(6,3),
"the_geom" public.geometry (LINESTRING, SRID_VALUE)
);


CREATE TABLE pol (
"id" integer PRIMARY KEY,
"inv_id" integer,
"sys_cat_state_id" integer,
"label_x" character varying(30),
"label_y" character varying(30),
"label_rotation" numeric(6,3),
"the_geom" (POLYGON,SRID_VALUE)
);


CREATE TABLE "element"(
"inv_id" integer PRIMARY KEY,
"cat_element_id" integer,
"nelement" integer
);


CREATE TABLE "element_x_inv" (
"element_id" varchar(16),
"inv_id" varchar(16),
CONSTRAINT element_x_inv_pkey PRIMARY KEY (element_id,inv_id)
);

----------------
-- INDEX
----------------


CREATE INDEX arc_node1 ON arc(node_1);
CREATE INDEX arc_node2 ON arc(node_2);

----------------
-- SPATIAL INDEX
----------------

CREATE INDEX arc_index ON arc USING GIST (the_geom);
CREATE INDEX node_index ON node USING GIST (the_geom);
CREATE INDEX link_index ON link USING GIST (the_geom);
CREATE INDEX pol_index ON pol USING GIST (the_geom);

