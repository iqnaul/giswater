﻿/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 1250

SET search_path= "SCHEMA_NAME", public, pg_catalog;

DROP FUNCTION IF EXISTS gw_trg_man_addfields_value_control() CASCADE;
CREATE OR REPLACE FUNCTION gw_trg_man_addfields_value_control()
  RETURNS trigger AS
$BODY$
DECLARE 
feature_type_aux varchar;
feature_new_aux varchar;
feature_old_aux varchar;
    
BEGIN
    
    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';

    feature_type_aux:= TG_ARGV[0];


    IF TG_OP ='UPDATE' THEN

		IF feature_type_aux='ARC' THEN
			feature_new_aux:= NEW.node_id;
			feature_old_aux:= OLD.node_id;	
		ELSIF feature_type_aux='NODE' THEN
			feature_new_aux:= NEW.arc_id;
			feature_old_aux:= OLD.arc_id;
		ELSIF feature_type_aux='CONNEC' THEN
			feature_new_aux:= NEW.connec_id;
			feature_old_aux:= OLD.connec_id;
		ELSIF feature_type_aux='GULLY' THEN
			feature_new_aux:= NEW.gully_id;
			feature_old_aux:= OLD.gully_id;
		END IF;

    	UPDATE man_addfields_value SET feature_id=feature_new_aux  WHERE feature_id=feature_old_aux;

    ELSIF TG_OP ='DELETE' THEN

    	IF feature_type_aux='ARC' THEN
			feature_old_aux:= OLD.node_id;	
		ELSIF feature_type_aux='NODE' THEN
			feature_old_aux:= OLD.arc_id;
		ELSIF feature_type_aux='CONNEC' THEN
			feature_old_aux:= OLD.connec_id;
		ELSIF feature_type_aux='GULLY' THEN
			feature_old_aux:= OLD.gully_id;
		END IF;
    
		DELETE FROM man_addfields_value WHERE feature_id=feature_old_aux;	

    END IF;

RETURN NEW;

END; 
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

DROP TRIGGER IF EXISTS gw_trg_man_addfields_value_node_control ON node;
CREATE TRIGGER gw_trg_man_addfields_value_node_control AFTER UPDATE OF node_id OR DELETE ON SCHEMA_NAME.node
FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.gw_trg_man_addfields_value_control('NODE');

DROP TRIGGER IF EXISTS gw_trg_man_addfields_value_arc_control ON arc;
CREATE TRIGGER gw_trg_man_addfields_value_arc_control AFTER UPDATE OF arc_id OR DELETE ON SCHEMA_NAME.arc
FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.gw_trg_man_addfields_value_control('ARC');

DROP TRIGGER IF EXISTS gw_trg_man_addfields_value_connec_control ON connec;
CREATE TRIGGER gw_trg_man_addfields_value_connec_control AFTER UPDATE OF connec_id OR DELETE ON SCHEMA_NAME.connec
FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.gw_trg_man_addfields_value_control('CONNEC');
  
DROP TRIGGER IF EXISTS gw_trg_man_addfields_value_gully_control ON gully;
CREATE TRIGGER gw_trg_man_addfields_value_gully_control AFTER UPDATE OF gully_id OR DELETE ON SCHEMA_NAME.gully
FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.gw_trg_man_addfields_value_control('GULLY');



  