/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


CREATE TABLE cfg_param_user (
id serial,
parameter varchar(50),
value varchar(50),
user_name text,
CONSTRAINT cfg_param_user_pkey PRIMARY KEY (parameter,user_name)
);


CREATE TABLE cfg_param_system (
id serial PRIMARY KEY,
parameter varchar(50),
value varchar(50),
data_type varchar(20),
context varchar(50),
descript text
);

CREATE TABLE cfg_user_x_expl(
id serial PRIMARY KEY,
exploitation_id integer,
user_name character varying(50)
);

-- ----------------------------
-- API
-- ----------------------------

CREATE TABLE cfg_api_layer_class (
layer_id integer PRIMARY KEY,
class_id varchar(30),
orderby integer
);

CREATE TABLE cfg_api_layer_parent (
cfg_api_layer_class_id integer,
parent_id integer
);

CREATE TABLE cfg_api_layer_child (
syd integer PRIMARY KEY,
table_parent varchar(50),
table_child varchar(50)
);

CREATE TABLE cfg_api_layer_tab (
cfg_api_layer_class_id integer,
tab_id integer,
did integer
);

CREATE TABLE cfg_api_layer_tab_tview (
id integer PRIMARY KEY,
tview_id integer,
did integer,
sql_text text
);



