/*
This file is part of Giswater 2.0
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/




CREATE OR REPLACE VIEW SCHEMA_NAME.v_ui_event_x_node AS 
SELECT
event_x_node.id,
event.event_type,
event_x_node.event_id,
event_x_node.node_id,
node.node_type,
event_x_node.parameter_id,
event_x_node.value,
event_x_node.position_id,
event_x_node.text,
event.timestamp,
event.user
FROM SCHEMA_NAME.event_x_node
JOIN SCHEMA_NAME.event ON event.id::text = event_x_node.event_id::text
JOIN SCHEMA_NAME.node ON SCHEMA_NAME.node.node_id::text = event_x_node.node_id::text
ORDER BY node_id;





CREATE OR REPLACE VIEW SCHEMA_NAME.v_ui_event_x_arc AS 
SELECT
event_x_arc.id,
event.event_type,
event_x_arc.event_id,
event_x_arc.arc_id,
arc.arccat_id,
event_x_arc.parameter_id,
event_x_arc.value,
event_x_arc.position_id,
event_x_arc.text,
event.startdate,
event.enddate,
event.timestamp,
event.user
FROM SCHEMA_NAME.event_x_arc
JOIN SCHEMA_NAME.event ON event.id::text = event_x_arc.event_id::text
JOIN SCHEMA_NAME.arc ON SCHEMA_NAME.arc.arc_id::text = event_x_arc.arc_id::text
ORDER BY arc_id;



CREATE OR REPLACE VIEW SCHEMA_NAME.v_ui_event_x_element AS 
SELECT
event_x_element.id,
node.node_id,
event.event_type,
event_x_element.event_id,
event_x_element.element_id,
element.elementcat_id,
event_x_element.parameter_id,
event_x_element.value,
event_x_element.position_id,
event_x_element.text,
event.timestamp,
event.user
FROM SCHEMA_NAME.event_x_element
JOIN SCHEMA_NAME.event ON event.id::text = event_x_element.event_id::text
JOIN SCHEMA_NAME.element ON SCHEMA_NAME.element.element_id::text = event_x_element.element_id::text
JOIN SCHEMA_NAME.element_x_node ON SCHEMA_NAME.element_x_node.element_id::text = event_x_element.element_id::text
JOIN SCHEMA_NAME.node ON SCHEMA_NAME.node.node_id::text = element_x_node.node_id::text
ORDER BY element_id;



CREATE OR REPLACE VIEW SCHEMA_NAME.v_ui_event_x_connec AS 
SELECT
event_x_connec.id,
event.event_type,
event_x_connec.event_id,
event_x_connec.connec_id,
connec.connecat_id,
event_x_connec.parameter_id,
event_x_connec.value,
event_x_connec.position_id,
event_x_connec.text,
event.timestamp,
event.user
FROM SCHEMA_NAME.event_x_connec
JOIN SCHEMA_NAME.event ON event.id::text = event_x_connec.event_id::text
JOIN SCHEMA_NAME.connec ON SCHEMA_NAME.connec.connec_id::text = event_x_connec.connec_id::text
ORDER BY connec_id;



CREATE OR REPLACE VIEW SCHEMA_NAME.v_ui_event_x_element_x_node AS 
 SELECT event_x_element.id,
    node.node_id,
    event.event_type,
    event_x_element.event_id,
    event_x_element.element_id,
    element.elementcat_id,
    event_x_element.parameter_id,
    event_x_element.value,
    event_x_element.position_id,
    event_x_element.text,
    event."timestamp",
    event."user"
   FROM SCHEMA_NAME.event_x_element
     JOIN SCHEMA_NAME.event ON event.id::text = event_x_element.event_id::text
     JOIN SCHEMA_NAME.element ON element.element_id::text = event_x_element.element_id::text
     JOIN SCHEMA_NAME.element_x_node ON element_x_node.element_id::text = event_x_element.element_id::text
     JOIN SCHEMA_NAME.node ON node.node_id::text = element_x_node.node_id::text
  ORDER BY event_x_element.element_id;
  
  
  
 CREATE OR REPLACE VIEW SCHEMA_NAME.v_ui_event_x_element_x_connec AS 
 SELECT event_x_element.id,
    connec.connec_id,
    event.event_type,
    event_x_element.event_id,
    event_x_element.element_id,
    element.elementcat_id,
    event_x_element.parameter_id,
    event_x_element.value,
    event_x_element.position_id,
    event_x_element.text,
    event."timestamp",
    event."user"
   FROM SCHEMA_NAME.event_x_element
     JOIN SCHEMA_NAME.event ON event.id::text = event_x_element.event_id::text
     JOIN SCHEMA_NAME.element ON element.element_id::text = event_x_element.element_id::text
     JOIN SCHEMA_NAME.element_x_connec ON element_x_connec.element_id::text = event_x_element.element_id::text
     JOIN SCHEMA_NAME.connec ON connec.connec_id::text = element_x_connec.connec_id::text
  ORDER BY event_x_element.element_id;



 CREATE OR REPLACE VIEW SCHEMA_NAME.v_ui_event_x_element_x_arc AS 
 SELECT event_x_element.id,
    arc.arc_id,
    event.event_type,
    event_x_element.event_id,
    event_x_element.element_id,
    element.elementcat_id,
    event_x_element.parameter_id,
    event_x_element.value,
    event_x_element.position_id,
    event_x_element.text,
    event."timestamp",
    event."user"
   FROM SCHEMA_NAME.event_x_element
     JOIN SCHEMA_NAME.event ON event.id::text = event_x_element.event_id::text
     JOIN SCHEMA_NAME.element ON element.element_id::text = event_x_element.element_id::text
     JOIN SCHEMA_NAME.element_x_arc ON element_x_arc.element_id::text = event_x_element.element_id::text
     JOIN SCHEMA_NAME.arc ON arc.arc_id::text = element_x_arc.arc_id::text
  ORDER BY event_x_element.element_id;



   