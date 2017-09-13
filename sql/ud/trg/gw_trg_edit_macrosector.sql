-- DROP FUNCTION "SCHEMA_NAME".gw_trg_edit_man_arc();

CREATE OR REPLACE FUNCTION "SCHEMA_NAME".gw_trg_edit_macrosector()
  RETURNS trigger AS
$BODY$
DECLARE 
	expl_id_int integer;

BEGIN

    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';

	
    IF TG_OP = 'INSERT' THEN
	
			/*
	        -- Sector ID
        IF (NEW.sector_id IS NULL) THEN
            IF ((SELECT COUNT(*) FROM sector) = 0) THEN
                RETURN audit_function(115,380);  
            END IF;
            NEW.sector_id:= (SELECT sector_id FROM sector WHERE ST_DWithin(NEW.the_geom, sector.the_geom,0.001) LIMIT 1);
            IF (NEW.sector_id IS NULL) THEN
                RETURN audit_function(120,380);          
            END IF;            
        END IF;
		*/
			
        -- FEATURE INSERT
				INSERT INTO macrosector (macrosector_id, name, descript,  the_geom, undelete)
				VALUES (NEW.macrosector_id, NEW.name, NEW.descript, NEW.the_geom, NEW.undelete);

		RETURN NEW;
		
    ELSIF TG_OP = 'UPDATE' THEN
   	-- FEATURE UPDATE
			UPDATE macrosector 
			SET macrosector_id=NEW.macrosector_id, name=NEW.name, descript=NEW.descript, the_geom=NEW.the_geom, undelete=NEW.undelete
			WHERE macrosector_id=NEW.macrosector_id;
		
        --PERFORM audit_function(2,340); 
        RETURN NEW;

		
		
     ELSIF TG_OP = 'DELETE' THEN  
	 -- FEATURE DELETE
		DELETE FROM macrosector WHERE macrosector_id = OLD.macrosector_id;		

		--PERFORM audit_function(3,340); 		
		RETURN NULL;
     
     END IF;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
  
  
  
DROP TRIGGER IF EXISTS gw_trg_edit_macrosector ON "SCHEMA_NAME".v_edit_macrosector;
CREATE TRIGGER gw_trg_edit_macrosector INSTEAD OF INSERT OR DELETE OR UPDATE ON "SCHEMA_NAME".v_edit_macrosector FOR EACH ROW EXECUTE PROCEDURE "SCHEMA_NAME".gw_trg_edit_macrosector('macrosector');



