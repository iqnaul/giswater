/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = "SCHEMA_NAME", public, pg_catalog;


CREATE TABLE "cat_mat_arc" (
"id" integer,
"value" varchar(50),
"descript" text,
"n" numeric(12,4),
"link" varchar(512)  ,
CONSTRAINT cat_mat_arc_pkey PRIMARY KEY (id)
);


CREATE TABLE "cat_mat_node" (
"id" integer,
"value" varchar(50),
"descript" text,
"link" varchar(512)  ,
CONSTRAINT cat_mat_node_pkey PRIMARY KEY (id)
);


CREATE TABLE "cat_mat_element" (
"id" integer,
"value" varchar(50),
"descript" text,
"link" varchar(512)  ,
CONSTRAINT cat_mat_element_pkey PRIMARY KEY (id)
);


CREATE TABLE "cat_element" (
"id" integer,
"value" varchar(50),
"descript" text,
"elementtype_id" varchar(30)  ,
"cat_mat_element_id" varchar(30)  ,
"geometry" varchar(30)  ,
"link" varchar(512)  ,
"cat_brand_id" integer  ,
"type" varchar(30)  ,
"cat_model_id" integer  ,
"svg" varchar(50),
"is_active" boolean,
CONSTRAINT cat_element_pkey PRIMARY KEY (id)
);


CREATE TABLE "cat_soil" (
"id" integer,
"value" varchar(50),
"descript" text,
"link" varchar(512),
"y_param" numeric(5,2),
"b" numeric(5,2),
"trenchlining" numeric(3,2),
"m3exc_cost" varchar (16),
"m3fill_cost" varchar (16),
"m3excess_cost" varchar (16),
"m2trenchl_cost" varchar (16),
CONSTRAINT cat_soil_pkey PRIMARY KEY (id)
);



CREATE TABLE "cat_builder" (
"id" integer,
"value" varchar(50),
"descript" text,
"link" varchar(512)  ,
CONSTRAINT cat_builder_pkey PRIMARY KEY (id)
);


CREATE TABLE "cat_work" (
"id" integer,
"value" varchar(50),
"descript" text,
"link" varchar(512),
workid_key1 character varying(30),
workid_key2 character varying(30),
builtdate date,
CONSTRAINT cat_work_pkey PRIMARY KEY (id)
);


CREATE TABLE "cat_owner" (
"id" integer,
"value" varchar(50),
"descript" text,,
"link" varchar(512)  ,
CONSTRAINT cat_owner_pkey PRIMARY KEY (id)
);


CREATE TABLE "cat_pavement" (
"id" integer,
"value" varchar(50),
"descript" text,
"link" varchar(512)  ,
"thickness" numeric(12,2) DEFAULT 0.00,
"m2_cost" varchar (16),
 CONSTRAINT cat_pavement_pkey PRIMARY KEY (id)
 );
 

 CREATE TABLE "cat_brand" (
"id" integer,
"value" varchar(50),
"descript" text,
"link" varchar(512),
 CONSTRAINT cat_brand_pkey PRIMARY KEY (id)
 );

 CREATE TABLE "cat_brand_model" (
"id" integer,
"value" varchar(50),
"descript" text,
"cat_brand_id" varchar (30),
"link" varchar(512)  ,
 CONSTRAINT cat_brand_type_pkey PRIMARY KEY (id)
 );


CREATE TABLE "cat_category" (
"id" integer,
"value" varchar(50),
"descript" text,
"category_type" varchar(50),
"feature_type" varchar(30),
"featurecat_id" varchar(300),
CONSTRAINT man_type_category_pkey PRIMARY KEY (id)
);


CREATE TABLE "cat_fluid" (
"id" integer,
"value" varchar(50),
"descript" text,
"fluid_type" varchar(50),
"feature_type" varchar(30),
"featurecat_id" varchar(300),
CONSTRAINT man_type_fluid_pkey PRIMARY KEY (id)
);


CREATE TABLE "cat_verified" (
"id" integer PRIMARY KEY,
"value" varchar(50),
"descript" text
);


CREATE TABLE "cat_user"(
"id" integer PRIMARY KEY,
"value" varchar(50),
"descript" text
);