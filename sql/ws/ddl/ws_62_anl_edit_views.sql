/*
This file is part of Giswater 2.0
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/
SET search_path = "SCHEMA_NAME", public, pg_catalog;

-- ----------------------------
-- MINCUT
-- ----------------------------

DROP VIEW IF EXISTS v_edit_anl_valve CASCADE;
CREATE OR REPLACE VIEW v_edit_anl_valve AS 
SELECT 
node.node_id,
cat_node.nodetype_id,
man_valve.type,
man_valve.opened,
man_valve.acessibility,
man_valve.broken,
man_valve.mincut_anl,
man_valve.hydraulic_anl,
node.the_geom
FROM node
JOIN cat_node ON node.nodecat_id::text=cat_node.id::text
JOIN man_valve ON node.node_id::text=man_valve.node_id::text
JOIN man_selector_valve ON cat_node.nodetype_id::text=man_selector_valve.id::text;