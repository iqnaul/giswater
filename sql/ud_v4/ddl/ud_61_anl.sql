﻿/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

SET search_path = "SCHEMA_NAME", public, pg_catalog;


CREATE TABLE "anl_flow_node" (
id serial NOT NULL PRIMARY KEY,
inv_id varchar (16) NOT NULL,
inv_cat_systype_id varchar (30),
exploitation_id integer,
context varchar (30),
user_name text DEFAULT "current_user"(),
the_geom public.geometry (POINT, SRID_VALUE)
);


CREATE TABLE "anl_flow_arc" (
id serial NOT NULL PRIMARY KEY,
inv_id varchar (16) NOT NULL,
inv_cat_systype_id varchar (30),
exploitation_id integer,
context varchar (30),
user_name text DEFAULT "current_user"(),
the_geom public.geometry (LINESTRING, SRID_VALUE)
);



CREATE INDEX anl_flow_node_index ON anl_flow_node USING GIST (the_geom);
CREATE INDEX anl_flow_arc_index ON anl_flow_arc USING GIST (the_geom);

