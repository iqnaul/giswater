/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


--FUNCTION NUMBER: XXXX


CREATE OR REPLACE FUNCTION "SCHEMA_NAME".gw_trg_edit_audit_review_arc()
  RETURNS trigger AS
$BODY$

DECLARE
	review_status integer;
	
BEGIN
EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';

	IF TG_OP = 'UPDATE' THEN
	
		SELECT review_status_id INTO review_status FROM audit_review_arc;
		
		IF NEW.is_validated IS TRUE THEN

			IF NEW.new_arccat_id IS NULL THEN
				RAISE EXCEPTION 'It is impossible to validate the arc % without assigning value of arccat_id', NEW.arc_id;
			END IF;
			
			UPDATE audit_review_arc SET new_arccat_id=NEW.new_arccat_id, is_validated=NEW.is_validated WHERE arc_id=NEW.arc_id;
			
			IF review_status=1 AND NEW.arc_id NOT IN (SELECT arc_id FROM arc) THEN 
			
				INSERT INTO v_edit_arc (arc_id, y1, y2, arc_type, arccat_id, annotation, observ, expl_id, the_geom)
				SELECT NEW.arc_id, new_y1, new_y2, new_arc_type, new_arccat_id, annotation, observ, expl_id, the_geom FROM audit_review_arc;
		
			ELSIF review_status=2 THEN
				UPDATE v_edit_arc SET the_geom=NEW.the_geom WHERE arc_id=NEW.arc_id;
					
			ELSIF review_status=2 or review_status=3 THEN

				UPDATE v_edit_arc SET y1=NEW.new_y1, y2=NEW.new_y2, arccat_id=NEW.new_arccat_id, arc_type=NEW.new_arc_type, annotation=NEW.annotation, observ=NEW.observ
				WHERE arc_id=NEW.arc_id;
	
			END IF;	
			
			
			DELETE FROM review_arc WHERE arc_id = NEW.arc_id;
		
		END IF;
		
	END IF;	

RETURN NEW;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

  
DROP TRIGGER IF EXISTS gw_trg_edit_audit_review_arc ON "SCHEMA_NAME".v_edit_audit_review_arc;
CREATE TRIGGER gw_trg_edit_audit_review_arc INSTEAD OF UPDATE ON "SCHEMA_NAME".v_edit_audit_review_arc 
FOR EACH ROW EXECUTE PROCEDURE "SCHEMA_NAME".gw_trg_edit_audit_review_arc();