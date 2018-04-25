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


CREATE SEQUENCE cat_grate_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


CREATE TABLE cat_arc_shape (
id integer NOT NULL PRIMARY KEY,
value varchar (50),
epa varchar(30),
tsect_id varchar(16),
curve_id varchar(16),
image varchar(50),
descript text,
is_active boolean
);


CREATE TABLE cat_node_shape (
id integer NOT NULL PRIMARY KEY,
value varchar (50),
descript text,
is_active boolean
);




CREATE TABLE cat_arc (
id integer DEFAULT nextval ('SCHEMA_NAME.cat_arc_seq'::regclass) NOT NULL,
value varchar (50),
cat_mat_arc_id integer,
cat_arc_shape_id integer,
geom1 numeric(12,4),
geom2 numeric(12,4) DEFAULT 0.00,
geom3 numeric(12,4) DEFAULT 0.00,
geom4 numeric(12,4) DEFAULT 0.00,
geom5 numeric(12,4) DEFAULT 0.00,
geom6 numeric(12,4) DEFAULT 0.00,
geom7 numeric(12,4) DEFAULT 0.00,
geom8 numeric(12,4) DEFAULT 0.00,
geom_r varchar(20)  ,
descript varchar(255)  ,
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
id integer  DEFAULT nextval ('SCHEMA_NAME.cat_node_seq'::regclass) NOT NULL,
value varchar (50),
cat_mat_node_id varchar (16)  ,
cat_node_shape_id character varying(50),
geom1 numeric (12,2),
geom2 numeric (12,2),
geom3 numeric (12,2),
value numeric (12,2),
descript varchar(255)  ,
link varchar(512)  ,
cat_brand_id integer,
cat_model_id integer,
svg varchar(50)  ,
estimated_y numeric (12,2),
cost_unit varchar (3) DEFAULT 'u',
cost varchar (16),
is_active boolean,
CONSTRAINT cat_node_pkey PRIMARY KEY (id)
);


CREATE TABLE cat_mat_grate (
id integer,
value varchar(50),
descript text,
link varchar(512)  ,
CONSTRAINT cat_mat_node_pkey PRIMARY KEY (id)
);

CREATE TABLE cat_grate (
id integer  DEFAULT nextval ('SCHEMA_NAME.cat_grate_seq'::regclass) NOT NULL,
value varchar (50),
cat_mat_grate_id varchar (16)  ,
length numeric(12,4),
width numeric(12,4) DEFAULT 0.00,
total_area numeric(12,4) DEFAULT 0.00,
efective_area numeric(12,4) DEFAULT 0.00,
n_barr_l numeric(12,4) DEFAULT 0.00,
n_barr_w numeric(12,4) DEFAULT 0.00,
n_barr_diag numeric(12,4) DEFAULT 0.00,
a_param numeric(12,4) DEFAULT 0.00,
b_param numeric(12,4) DEFAULT 0.00,
descript text,
link varchar(512)  ,
cat_brand_id varchar(30)  ,
cat_model_id varchar(30)  ,
svg varchar(50)  ,
cost_ut character varying(16),
is_active boolean,
CONSTRAINT cat_grate_pkey PRIMARY KEY (id)
);
