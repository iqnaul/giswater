/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

 
 CREATE SEQUENCE cat_node_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE cat_arc_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



 CREATE TABLE cat_presszone (
id integer,
value varchar(50),
descript text,
expl_id integer,
link varchar(512) ,
 CONSTRAINT cat_presszone_pkey PRIMARY KEY (id)
 );



CREATE TABLE cat_arc (
id integer DEFAULT nextval('SCHEMA_NAME.cat_arc_seq'::regclass) NOT NULL,
value varchar (50),
arc_type_id varchar(30),
cat_mat_arc_id varchar(30),
pnom varchar(16)  ,
dnom varchar(16)  ,
dint numeric(12,5),
dext numeric(12,5),
descript text,
link varchar(512)  ,
cat_brand_id integer,
cat_model_id integer,
svg varchar(50)  ,
z1 numeric (12,2),
z2 numeric (12,2),
width numeric (12,2),
area numeric (12,4),
estimated_depth numeric (12,2),
bulk numeric (12,2),
cost_unit varchar (3) DEFAULT 'm',
cost varchar (16),
m2bottom_cost varchar (16),
m3protec_cost varchar (16),
is_active boolean,
CONSTRAINT cat_arc_pkey PRIMARY KEY (id)
);


CREATE TABLE cat_node (
id integer DEFAULT nextval('SCHEMA_NAME.cat_node_seq'::regclass) NOT NULL,
value varchar (50),
node_type_id varchar(30) ,
cat_mat_id varchar(30)  ,
pnom varchar(16)  ,
dnom varchar(16)  ,
dint numeric(12,5),
dext numeric(12,5),
shape character varying(50),
descript text,
link varchar(512)  ,
cat_brand_id integer,
cat_model_id integer,
svg varchar(50)  ,
estimated_depth numeric (12,2),
cost_unit varchar (3) DEFAULT 'u',
cost varchar (16),
is_active boolean,
CONSTRAINT cat_node_pkey PRIMARY KEY (id)
);

