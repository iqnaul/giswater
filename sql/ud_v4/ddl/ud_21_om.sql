/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

SET search_path = "SCHEMA_NAME", public, pg_catalog;


CREATE TABLE om_profile_cat)(
id integer PRIMARY KEY,
value varchar(50),
descript text
);


CREATE TABLE om_profile_value
(
  id serial NOT NULL PRIMARY KEY,
  om_profile_cat_id integer,
  inv_id integer,
  start_point_inv_id integer,
  end_point_inv_id integer
);

