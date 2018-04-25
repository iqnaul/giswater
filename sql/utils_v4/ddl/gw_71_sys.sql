/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = "SCHEMA_NAME", public, pg_catalog;


CREATE TABLE sys_cat_class (
id integer varchar(30) PRIMARY KEY,
value varchar(30)
);

CREATE TABLE sys_cat_state (
id int2 PRIMARY KEY, 
value varchar(30),
observ text
);

CREATE TABLE sys_cat_statetype (
id int2 NOT NULL PRIMARY KEY,
value varchar(30), 
sys_cat_state_id int2,
is_operative boolean
);

CREATE TABLE sys_cat_field (
id integer PRIMARY KEY,
inv_cat_systype_id integer,
column_id text,
datatype_id text,
is_mandatory boolean,
field_length integer,
num_decimals integer,
default_value text
);

CREATE TABLE sys_api_field (
id integer PRIMARY KEY,
inv_cat_systype_id integer,
column_id text,
datatype_id text,
widgettype_id integer,
widget_dim ?,
is_mandatory boolean,
is_combo_new_val boolean,
is_editable boolean,
is_clickable boolean,
default_value text,
placeholder text,
form_label text,
sql_text text,
web_publish boolean
);

CREATE TABLE sys_api_field_vdomain (
sys_api_fields_id integer,
id serial,
value varchar(30),
descript text
);

-- ----------------------------
-- AUDIT
-- ----------------------------

CREATE TABLE sys_cat_fprocess (
id integer NOT NULL PRIMARY KEY,
fprocess_name varchar(50),
context varchar (30),
fprocess_i18n varchar (50),
project_type varchar(6)
);

CREATE TABLE sys_cat_function (
id integer NOT NULL PRIMARY KEY,
function_name text NOT NULL,
project_type text,
function_type text,
input_params text,
return_type text,
context text,
descript text,
sys_role_id text
);

-- ----------------------------
-- EPA
-- ----------------------------

CREATE TABLE sys_cat_epatype (
id integer NOT NULL PRIMARY KEY,
value varchar(30),
class_id integer
);

CREATE TABLE sys_sel_inp_result (
id serial NOT NULL PRIMARY KEY,
result_id varchar(30),
user_name text
);

CREATE TABLE sys_sel_rpt_result (
id serial NOT NULL PRIMARY KEY, 
result_id varchar(30) ,
user_name text
);

CREATE TABLE sys_sel_rpt_hourly (
id serial NOT NULL,
time varchar(100),
user_name text,
CONSTRAINT sys_sel_rpt_hourly_pkey PRIMARY KEY (id,user_name)
);

CREATE TABLE sys_sel_rpt_compare (
id serial NOT NULL,
result_id varchar(30),
user_name text,
CONSTRAINT sys_sel_rpt_compare_pkey PRIMARY KEY (id,user_name)
);

CREATE TABLE sys_sel_sector(
id serial NOT NULL,
sector_id integer,
user_name text,
CONSTRAINT sys_sel_sector_pkey PRIMARY KEY (id,user_name)
);

CREATE TABLE sys_sel_dscenario (
id serial NOT NULL,
dscenario_id integer,
user_name text,
CONSTRAINT sys_sel_dscenario_pkey PRIMARY KEY (id,user_name)
);

-- ----------------------------
-- SELECTOR
-- ----------------------------

CREATE TABLE sys_sel_workcat (
id serial NOT NULL,
cat_work_id text,
user_name text,
CONSTRAINT sys_sel_workcat_pkey PRIMARY KEY (id,user_name)
);

CREATE TABLE sys_sel_audit (
id serial NOT NULL,
fprocesscat_id integer,
user_name text,
CONSTRAINT sys_sel_audit_pkey PRIMARY KEY (id,user_name)
);

CREATE TABLE sys_sel_date (
id serial NOT NULL,
from_date date,
to_date date,
context varchar(30),
user_name text,
CONSTRAINT sys_sel_date_pkey PRIMARY KEY (id,user_name)
);

CREATE TABLE sys_sel_expl (
id serial NOT NULL,
exploitation_id integer,
user_name text,
CONSTRAINT sys_sel_expl_pkey PRIMARY KEY (id,user_name)
);

CREATE TABLE sys_sel_state (
sys_cat_state integer,
user_name text,
CONSTRAINT sys_sel_state_pkey PRIMARY KEY (id,user_name)
);

CREATE TABLE sys_sel_psector (
plan_psector_id integer,
user_name text,
CONSTRAINT sys_sel_psector_pkey PRIMARY KEY (plan_psector_id,user_name)
);

CREATE TABLE sys_sel_plan_result (
epa_rpt_cat_result_id integer,
user_name text,
CONSTRAINT sys_sel_plan_result_pkey PRIMARY KEY (epa_rpt_cat_result_id,user_name)
);

