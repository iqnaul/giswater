/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


CREATE TABLE cfg_mincut_valve (
id varchar(50) PRIMARY KEY
);

CREATE TABLE cfg_mincut_inlet (
node_id integer,
expl_id integer
CONSTRAINT cfg_mincut_inlet_pkey (node_id,expl_id)
);
