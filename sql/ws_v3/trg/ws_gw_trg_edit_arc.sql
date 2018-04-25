﻿/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 1302


CREATE OR REPLACE FUNCTION "SCHEMA_NAME".gw_trg_edit_arc()
  RETURNS trigger AS
$BODY$
DECLARE 
    inp_table varchar;
	man_table varchar;
    v_sql varchar;
    arc_id_seq int8;
	count_aux integer;
	promixity_buffer_aux double precision;
	edit_enable_arc_nodes_update_aux boolean;
	new_arc_type_aux text;
	old_arc_type_aux text;
	query_text text;
	
BEGIN

    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';
	
	promixity_buffer_aux = (SELECT "value" FROM config_param_system WHERE "parameter"='proximity_buffer');
	edit_enable_arc_nodes_update_aux = (SELECT "value" FROM config_param_system WHERE "parameter"='edit_enable_arc_nodes_update');

    
    IF TG_OP = 'INSERT' THEN
    
        -- Arc ID
        IF (NEW.arc_id IS NULL) THEN
          --  PERFORM setval('urn_id_seq', gw_fct_urn(),true);
            NEW.arc_id:= (SELECT nextval('urn_id_seq'));
        END IF;

		-- code
		IF (NEW.code IS NULL) THEN
			NEW.code = NEW.arc_id;
		END IF;
              
        -- Arc catalog ID
		IF (NEW.arccat_id IS NULL) THEN
			IF ((SELECT COUNT(*) FROM cat_arc) = 0) THEN
				RETURN audit_function(1020,1302); 
			END IF; 
			NEW.arccat_id:= (SELECT "value" FROM config_param_user WHERE "parameter"='pipecat_vdefault' AND "cur_user"="current_user"() LIMIT 1);
			IF (NEW.arccat_id IS NULL) THEN
			NEW.arccat_id := (SELECT arccat_id from arc WHERE ST_DWithin(NEW.the_geom, arc.the_geom,0.001) LIMIT 1);
			IF (NEW.arccat_id IS NULL) THEN
				NEW.arccat_id := (SELECT id FROM cat_arc LIMIT 1);
			END IF;       
		END IF;
		END IF;
        
        -- Sector ID
        IF (NEW.sector_id IS NULL) THEN
			IF ((SELECT COUNT(*) FROM sector) = 0) THEN
                RETURN audit_function(1008,1302);  
			END IF;
				SELECT count(*)into count_aux FROM sector WHERE ST_DWithin(NEW.the_geom, sector.the_geom,0.001);
			IF count_aux = 1 THEN
				NEW.sector_id = (SELECT sector_id FROM sector WHERE ST_DWithin(NEW.the_geom, sector.the_geom,0.001) LIMIT 1);
			ELSIF count_aux > 1 THEN
				NEW.sector_id =(SELECT sector_id FROM v_edit_node WHERE ST_DWithin(NEW.the_geom, v_edit_node.the_geom, promixity_buffer_aux) 
				order by ST_Distance (NEW.the_geom, v_edit_node.the_geom) LIMIT 1);
			END IF;	
			IF (NEW.sector_id IS NULL) THEN
				NEW.sector_id := (SELECT "value" FROM config_param_user WHERE "parameter"='sector_vdefault' AND "cur_user"="current_user"() LIMIT 1);
			END IF;
			IF (NEW.sector_id IS NULL) THEN
                RETURN audit_function(1010,1302,NEW.arc_id);          
            END IF;            
        END IF;
        
	-- Dma ID
        IF (NEW.dma_id IS NULL) THEN
			IF ((SELECT COUNT(*) FROM dma) = 0) THEN
                RETURN audit_function(1012,1302);  
            END IF;
				SELECT count(*)into count_aux FROM dma WHERE ST_DWithin(NEW.the_geom, dma.the_geom,0.001);
			IF count_aux = 1 THEN
				NEW.dma_id := (SELECT dma_id FROM dma WHERE ST_DWithin(NEW.the_geom, dma.the_geom,0.001) LIMIT 1);
			ELSIF count_aux > 1 THEN
				NEW.dma_id =(SELECT dma_id FROM v_edit_node WHERE ST_DWithin(NEW.the_geom, v_edit_node.the_geom, promixity_buffer_aux) 
				order by ST_Distance (NEW.the_geom, v_edit_node.the_geom) LIMIT 1);
			END IF;
			IF (NEW.dma_id IS NULL) THEN
				NEW.dma_id := (SELECT "value" FROM config_param_user WHERE "parameter"='dma_vdefault' AND "cur_user"="current_user"() LIMIT 1);
			END IF; 
            IF (NEW.dma_id IS NULL) THEN
                RETURN audit_function(1014,1302,NEW.arc_id);  
            END IF;            
        END IF;
		
	    -- State
        IF (NEW.state IS NULL) THEN
            NEW.state := (SELECT "value" FROM config_param_user WHERE "parameter"='state_vdefault' AND "cur_user"="current_user"() LIMIT 1);
        END IF;
		
		-- State_type
		IF (NEW.state_type IS NULL) THEN
			NEW.state_type := (SELECT "value" FROM config_param_user WHERE "parameter"='statetype_vdefault' AND "cur_user"="current_user"() LIMIT 1);
        END IF;
		
		-- Workcat_id
        IF (NEW.workcat_id IS NULL) THEN
            NEW.workcat_id := (SELECT "value" FROM config_param_user WHERE "parameter"='workcat_vdefault' AND "cur_user"="current_user"() LIMIT 1);
        END IF;
		
		-- Ownercat_id
        IF (NEW.ownercat_id IS NULL) THEN
            NEW.ownercat_id := (SELECT "value" FROM config_param_user WHERE "parameter"='ownercat_vdefault' AND "cur_user"="current_user"() LIMIT 1);
        END IF;
		
		-- Soilcat_id
        IF (NEW.soilcat_id IS NULL) THEN
            NEW.soilcat_id := (SELECT "value" FROM config_param_user WHERE "parameter"='soilcat_vdefault' AND "cur_user"="current_user"() LIMIT 1);
        END IF;
		
		-- Verified
        IF (NEW.verified IS NULL) THEN
            NEW.verified := (SELECT "value" FROM config_param_user WHERE "parameter"='verified_vdefault' AND "cur_user"="current_user"() LIMIT 1);
        END IF;
		
		-- Presszone
        IF (NEW.presszonecat_id IS NULL) THEN
            NEW.presszonecat_id := (SELECT "value" FROM config_param_user WHERE "parameter"='presszone_vdefault' AND "cur_user"="current_user"() LIMIT 1);
        END IF;
		
		--Inventory
		IF (NEW.inventory IS NULL) THEN
			NEW.inventory :='TRUE';
		END IF; 
		
		-- Exploitation
		IF (NEW.expl_id IS NULL) THEN
			NEW.expl_id := (SELECT "value" FROM config_param_user WHERE "parameter"='exploitation_vdefault' AND "cur_user"="current_user"() LIMIT 1);
			IF (NEW.expl_id IS NULL) THEN
				NEW.expl_id := (SELECT expl_id FROM exploitation WHERE ST_DWithin(NEW.the_geom, exploitation.the_geom,0.001) LIMIT 1);
				IF (NEW.expl_id IS NULL) THEN
					PERFORM audit_function(2012,1302,NEW.arc_id);
				END IF;		
			END IF;
		END IF;

		-- Municipality 
		IF (NEW.muni_id IS NULL) THEN
			NEW.muni_id := (SELECT "value" FROM config_param_user WHERE "parameter"='municipality_vdefault' AND "cur_user"="current_user"() LIMIT 1);
			IF (NEW.muni_id IS NULL) THEN
				NEW.muni_id := (SELECT muni_id FROM ext_municipality WHERE ST_DWithin(NEW.the_geom, ext_municipality.the_geom,0.001) LIMIT 1);
				IF (NEW.muni_id IS NULL) THEN
					PERFORM audit_function(2024,1302,NEW.arc_id);
				END IF;	
			END IF;
		END IF;
		
		-- Builtdate
		IF (NEW.builtdate IS NULL) THEN
			NEW.builtdate :=(SELECT "value" FROM config_param_user WHERE "parameter"='builtdate_vdefault' AND "cur_user"="current_user"() LIMIT 1);
		END IF;  
		
        -- Set EPA type
       NEW.epa_type = 'PIPE';   

    
        -- FEATURE INSERT
    		INSERT INTO arc (arc_id, code, node_1, node_2, arccat_id, epa_type, sector_id, "state", state_type, annotation, observ,"comment",custom_length,dma_id, presszonecat_id, soilcat_id, function_type, category_type, fluid_type, location_type,
					workcat_id, workcat_id_end, buildercat_id, builtdate, enddate, ownercat_id, muni_id, postcode, streetaxis_id, postnumber, postcomplement, streetaxis2_id, postnumber2, postcomplement2,
					descript,verified,the_geom,undelete,label_x,label_y,label_rotation, publish, inventory, expl_id,num_value)
					VALUES (NEW.arc_id,NEW.code, null, null, NEW.arccat_id, NEW.epa_type, NEW.sector_id, NEW.state, NEW.state_type, NEW.annotation, NEW.observ, NEW."comment", NEW.custom_length,NEW.dma_id, NEW.presszonecat_id, NEW.soilcat_id, NEW.function_type, 
					NEW.category_type, NEW.fluid_type, NEW.location_type, NEW.workcat_id, NEW.workcat_id_end, NEW.buildercat_id, NEW.builtdate, NEW.enddate, NEW.ownercat_id, 
					NEW.muni_id, NEW.postcode, NEW.streetaxis_id, NEW.postnumber, NEW.postcomplement, NEW.streetaxis2_id, NEW.postnumber2, NEW.postcomplement2,
					NEW.descript, NEW.verified, NEW.the_geom,NEW.undelete, NEW.label_x,NEW.label_y,NEW.label_rotation, 
					NEW.publish, NEW.inventory, NEW.expl_id, NEW.num_value);


		IF edit_enable_arc_nodes_update_aux IS TRUE THEN
				UPDATE arc SET node_1=NEW.node_1, node_2=NEW.node_2 WHERE arc_id=NEW.arc_id;
		END IF;

		

        -- EPA INSERT
        IF (NEW.epa_type = 'PIPE') THEN 
            inp_table:= 'inp_pipe';
            v_sql:= 'INSERT INTO '||inp_table||' (arc_id) VALUES ('||quote_literal(NEW.arc_id)||')';
            EXECUTE v_sql;
        END IF;

        -- MAN INSERT      
        man_table := (SELECT arc_type.man_table FROM arc_type JOIN cat_arc ON (((arc_type.id)::text = (cat_arc.arctype_id)::text)) WHERE cat_arc.id=NEW.arccat_id);
        IF man_table IS NOT NULL THEN
            v_sql:= 'INSERT INTO '||man_table||' (arc_id) VALUES ('||quote_literal(NEW.arc_id)||')';    
            EXECUTE v_sql;
        END IF;
     
        RETURN NEW;
    
    ELSIF TG_OP = 'UPDATE' THEN

    	-- Arc type
    	IF (NEW.arccat_id != OLD.arccat_id) THEN
			new_arc_type_aux= (SELECT type FROM arc_type JOIN cat_arc ON arc_type.id=arctype_id where cat_arc.id=NEW.arccat_id);
			old_arc_type_aux= (SELECT type FROM arc_type JOIN cat_arc ON arc_type.id=arctype_id where cat_arc.id=OLD.arccat_id);
			IF new_arc_type_aux != old_arc_type_aux THEN
				query_text='INSERT INTO man_'||lower(new_arc_type_aux)||' (arc_id) VALUES ('||NEW.arc_id||')';
				EXECUTE query_text;
				query_text='DELETE FROM man_'||lower(old_arc_type_aux)||' WHERE arc_id='||quote_literal(OLD.arc_id);
				EXECUTE query_text;
			END IF;
		END IF;

	
		-- State
		IF (NEW.state != OLD.state) THEN
			UPDATE arc SET state=NEW.state WHERE arc_id = OLD.arc_id;
		END IF;
		
		-- State_type
		IF NEW.state=0 AND OLD.state=1 THEN
			IF (SELECT state FROM value_state_type WHERE id=NEW.state_type) != NEW.state THEN
			NEW.state_type=(SELECT "value" FROM config_param_user WHERE parameter='statetype_end_vdefault' AND "cur_user"="current_user"() LIMIT 1);
				IF NEW.state_type IS NULL THEN
				NEW.state_type=(SELECT id from value_state_type WHERE state=0 LIMIT 1);
					IF NEW.state_type IS NULL THEN
					RETURN audit_function(2110,1318);
					END IF;
				END IF;
			END IF;
		END IF;
			
		-- The geom
		IF (NEW.the_geom IS DISTINCT FROM OLD.the_geom)  THEN
			UPDATE arc SET the_geom=NEW.the_geom WHERE arc_id = OLD.arc_id;
		END IF;
	

    
        IF (NEW.epa_type != OLD.epa_type) THEN    
         
            IF (OLD.epa_type = 'PIPE') THEN
                inp_table:= 'inp_pipe';            
                v_sql:= 'DELETE FROM '||inp_table||' WHERE arc_id = '||quote_literal(OLD.arc_id);
                EXECUTE v_sql;
            END IF;
			inp_table := NULL;


            IF (NEW.epa_type = 'PIPE') THEN
                inp_table:= 'inp_pipe';   
                v_sql:= 'INSERT INTO '||inp_table||' (arc_id) VALUES ('||quote_literal(NEW.arc_id)||')';
                EXECUTE v_sql;
            END IF;

        END IF;

    
UPDATE arc 
			SET code=NEW.code, arccat_id=NEW.arccat_id, epa_type=NEW.epa_type, sector_id=NEW.sector_id,  state_type=NEW.state_type, annotation= NEW.annotation, "observ"=NEW.observ, 
				"comment"=NEW.comment, custom_length=NEW.custom_length, dma_id=NEW.dma_id, soilcat_id=NEW.soilcat_id, function_type=NEW.function_type, category_type=NEW.category_type, 
				fluid_type=NEW.fluid_type, 
				location_type=NEW.location_type, workcat_id=NEW.workcat_id, workcat_id_end=NEW.workcat_id_end, buildercat_id=NEW.buildercat_id, builtdate=NEW.builtdate, enddate=NEW.enddate,
				ownercat_id=NEW.ownercat_id, muni_id=NEW.muni_id, streetaxis_id=NEW.streetaxis_id, postcode=NEW.postcode,streetaxis2_id=NEW.streetaxis2_id, postnumber=NEW.postnumber,
				postnumber2=NEW.postnumber2,descript=NEW.descript, the_geom=NEW.the_geom, 
				postcomplement=NEW.postcomplement, postcomplement2=NEW.postcomplement2, verified=NEW.verified, undelete=NEW.undelete, label_x=NEW.label_x,
				label_y=NEW.label_y,label_rotation=NEW.label_rotation, publish=NEW.publish, inventory=NEW.inventory, expl_id=NEW.expl_id, num_value=NEW.num_value
			WHERE arc_id=OLD.arc_id;

        RETURN NEW;

     ELSIF TG_OP = 'DELETE' THEN

		PERFORM gw_fct_check_delete(OLD.arc_id, 'ARC');			 
        
		DELETE FROM arc WHERE arc_id = OLD.arc_id;
        RETURN NULL;
     
     END IF;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
  

DROP TRIGGER IF EXISTS gw_trg_edit_arc ON "SCHEMA_NAME".v_edit_arc;
CREATE TRIGGER gw_trg_edit_arc INSTEAD OF INSERT OR DELETE OR UPDATE ON "SCHEMA_NAME".v_edit_arc
FOR EACH ROW EXECUTE PROCEDURE "SCHEMA_NAME".gw_trg_edit_arc();


      