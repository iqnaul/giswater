/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = "SCHEMA_NAME", public, pg_catalog;

INSERT INTO om_visit_cat VALUES (1, 'prueba num.1','2017-12-31', NULL, NULL, TRUE);
INSERT INTO om_visit_cat VALUES (2, 'prueba num.2','2017-12-31', NULL, NULL, FALSE);
INSERT INTO om_visit_cat VALUES (3, 'prueba num.3','2017-12-31', NULL, NULL, TRUE);
INSERT INTO om_visit_cat VALUES (4, 'prueba num.4','2017-12-31', NULL, NULL, TRUE);

INSERT INTO om_visit_parameter_type VALUES ('INSPECTION');
INSERT INTO om_visit_parameter_type VALUES ('REHABIT');

INSERT INTO om_visit_parameter_form_type VALUES ('event_standard');
INSERT INTO om_visit_parameter_form_type VALUES ('event_ud_arc_rehabit');
INSERT INTO om_visit_parameter_form_type VALUES ('event_ud_arc_standard');

INSERT INTO om_visit_parameter VALUES ('insp_arc_p1', NULL, 'REHABIT', 'ARC', 'TEXT', NULL, 'Inspection arc parameter 1', 'event_ud_arc_rehabit', 'a');
INSERT INTO om_visit_parameter VALUES ('insp_arc_p2', NULL, 'REHABIT', 'ARC', 'TEXT', NULL, 'Inspection arc parameter 2', 'event_ud_arc_rehabit', 'b');
INSERT INTO om_visit_parameter VALUES ('insp_arc_p3', NULL, 'INSPECTION', 'ARC', 'TEXT', NULL, 'Inspection arc parameter 3', 'event_ud_arc_standard', 'c');
INSERT INTO om_visit_parameter VALUES ('insp_connec_p1', NULL, 'INSPECTION', 'CONNEC', 'TEXT', NULL, 'Inspection connec parameter 1', 'event_standard', 'd');
INSERT INTO om_visit_parameter VALUES ('insp_connec_p2', NULL, 'INSPECTION', 'CONNEC', 'TEXT', NULL, 'Inspection connec parameter 2', 'event_standard', 'e');
INSERT INTO om_visit_parameter VALUES ('insp_node_p1', NULL, 'INSPECTION', 'NODE', 'TEXT', NULL, 'Inspection node parameter 1', 'event_standard', 'f');
INSERT INTO om_visit_parameter VALUES ('insp_node_p2', NULL, 'INSPECTION', 'NODE', 'TEXT', NULL, 'Inspection node parameter 2', 'event_standard', 'g');
INSERT INTO om_visit_parameter VALUES ('insp_node_p3', NULL, 'INSPECTION', 'NODE', 'TEXT', NULL, 'Inspection node parameter 3', 'event_standard', 'i');
