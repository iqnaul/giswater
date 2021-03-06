/*
This file is part of Giswater 2.0
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association

*/

SET search_path = "SCHEMA_NAME", public, pg_catalog;

-- ----------------------------
-- Default values of column views
-- ----------------------------

ALTER TABLE element ALTER COLUMN state SET DEFAULT 'ON_SERVICE';
ALTER TABLE element ALTER COLUMN verified SET DEFAULT 'TO REVIEW';


-- Custom values (User can customize other fields....)