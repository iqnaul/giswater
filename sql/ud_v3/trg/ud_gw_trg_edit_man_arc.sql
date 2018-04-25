﻿/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


--FUNCTION CODE: 1212

	CREATE OR REPLACE FUNCTION "SCHEMA_NAME".gw_trg_edit_man_arc() RETURNS trigger AS
	$BODY$
	DECLARE 
		inp_table varchar;
		man_table varchar;
		new_man_table varchar;
		old_man_table varchar;
		v_sql varchar;
		v_sql2 varchar;
		man_table_2 varchar;
		arc_id_seq int8;
		count_aux integer;
		promixity_buffer_aux double precision;
		edit_enable_arc_nodes_update_aux boolean;
		
	BEGIN

		EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';
		man_table:= TG_ARGV[0];
		man_table_2:=man_table;
		
		promixity_buffer_aux = (SELECT "value" FROM config_param_system WHERE "parameter"='proximity_buffer');
		edit_enable_arc_nodes_update_aux = (SELECT "value" FROM config_param_system WHERE "parameter"='edit_enable_arc_nodes_update');

		IF TG_OP = 'INSERT' THEN   
			-- Arc ID
			IF (NEW.arc_id IS NULL) THEN
			NEW.arc_id:= (SELECT nextval('urn_id_seq'));
			END IF;

			 -- Arc type
			IF (NEW.arc_type IS NULL) THEN
				IF ((SELECT COUNT(*) FROM arc_type) = 0) THEN
					RETURN audit_function(1018,1212);  
				END IF;
				NEW.arc_type:= (SELECT id FROM arc_type WHERE arc_type.man_table=man_table_2 LIMIT 1);   
			END IF;

			 -- Epa type
			IF (NEW.epa_type IS NULL) THEN
				NEW.epa_type:= (SELECT epa_default FROM arc_type WHERE arc_type.id=NEW.arc_type)::text;   
			END IF;
			
			-- Arc catalog ID
			IF (NEW.arccat_id IS NULL) THEN
				IF ((SELECT COUNT(*) FROM cat_arc) = 0) THEN
					RETURN audit_function(1020,1212); 
				END IF; 
					NEW.arccat_id:= (SELECT "value" FROM config_param_user WHERE "parameter"='arccat_vdefault' AND "cur_user"="current_user"() LIMIT 1);
				IF (NEW.arccat_id IS NULL) THEN
					NEW.arccat_id := (SELECT arccat_id from arc WHERE ST_DWithin(NEW.the_geom, arc.the_geom,0.001) LIMIT 1);
				END IF;
				IF (NEW.arccat_id IS NULL) THEN
						NEW.arccat_id := (SELECT id FROM cat_arc LIMIT 1);
				END IF;       
			END IF;
				
			-- Sector ID
			IF (NEW.sector_id IS NULL) THEN
				IF ((SELECT COUNT(*) FROM sector) = 0) THEN
					RETURN audit_function(1008,1212);  
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
					RETURN audit_function(1010,1212,NEW.arc_id);          
				END IF;            
			END IF;
			
		-- Dma ID
			IF (NEW.dma_id IS NULL) THEN
				IF ((SELECT COUNT(*) FROM dma) = 0) THEN
					RETURN audit_function(1012,1212);  
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
					RETURN audit_function(1014,1212,NEW.arc_id);  
				END IF;            
			END IF;
				
			-- Verified
			IF (NEW.verified IS NULL) THEN
				NEW.verified := (SELECT "value" FROM config_param_user WHERE "parameter"='verified_vdefault' AND "cur_user"="current_user"() LIMIT 1);
			END IF;

			-- State
			IF (NEW.state IS NULL) THEN
				NEW.state := (SELECT "value" FROM config_param_user WHERE "parameter"='state_vdefault' AND "cur_user"="current_user"() LIMIT 1);
			END IF;
			
			-- State_type
			--IF (NEW.state_type IS NULL) THEN
				NEW.state_type := (SELECT "value" FROM config_param_user WHERE "parameter"='statetype_vdefault' AND "cur_user"="current_user"() LIMIT 1);
			--END IF;
			
   
			-- Exploitation
			IF (NEW.expl_id IS NULL) THEN
				NEW.expl_id := (SELECT "value" FROM config_param_user WHERE "parameter"='exploitation_vdefault' AND "cur_user"="current_user"() LIMIT 1);
				IF (NEW.expl_id IS NULL) THEN
					NEW.expl_id := (SELECT expl_id FROM exploitation WHERE ST_DWithin(NEW.the_geom, exploitation.the_geom,0.001) LIMIT 1);
					IF (NEW.expl_id IS NULL) THEN
						PERFORM audit_function(2012,1212,NEW.arc_id);
					END IF;		
				END IF;
			END IF;
			
			-- Municipality 
			IF (NEW.muni_id IS NULL) THEN
				NEW.muni_id := (SELECT "value" FROM config_param_user WHERE "parameter"='municipality_vdefault' AND "cur_user"="current_user"() LIMIT 1);
				IF (NEW.muni_id IS NULL) THEN
					NEW.muni_id := (SELECT muni_id FROM ext_municipality WHERE ST_DWithin(NEW.the_geom, ext_municipality.the_geom,0.001) LIMIT 1);
					IF (NEW.muni_id IS NULL) THEN
						PERFORM audit_function(2024,1212,NEW.arc_id);
					END IF;	
				END IF;
			END IF;

			--Inventory
			IF (NEW.inventory IS NULL) THEN
				NEW.inventory :='TRUE';
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

			--Builtdate
			IF (NEW.builtdate IS NULL) THEN
				NEW.builtdate:=(SELECT "value" FROM config_param_user WHERE "parameter"='builtdate_vdefault' AND "cur_user"="current_user"() LIMIT 1);
			END IF;
		
			-- FEATURE INSERT
			INSERT INTO arc (arc_id, code, node_1, node_2, y1, y2, custom_y1, custom_y2, elev1, elev2, custom_elev1, custom_elev2, arc_type, arccat_id, epa_type, sector_id, "state", state_type,
			annotation, observ, "comment", inverted_slope, custom_length, dma_id, soilcat_id, function_type, category_type, fluid_type, location_type, workcat_id, workcat_id_end, buildercat_id, 
			builtdate, enddate, ownercat_id, muni_id, streetaxis_id, postcode, streetaxis2_id, postnumber, postnumber2, postcomplement, postcomplement2, descript, link, verified, the_geom,undelete,label_x,label_y, label_rotation, expl_id, publish, inventory,
			uncertain, num_value) 
			VALUES (NEW.arc_id, NEW.code, NEW.node_1, NEW.node_2, NEW.y1, NEW.y2, NEW.custom_y1, NEW.custom_y2, NEW.elev1, NEW.elev2, 
			NEW.custom_elev1, NEW.custom_elev2,NEW.arc_type, NEW.arccat_id, NEW.epa_type, NEW.sector_id, NEW.state, NEW.state_type, NEW.annotation, NEW.observ, NEW.comment, 
			NEW.inverted_slope, NEW.custom_length, NEW.dma_id, NEW.soilcat_id, NEW.function_type, NEW.category_type, NEW.fluid_type, 
			NEW.location_type, NEW.workcat_id,NEW.workcat_id_end,NEW.buildercat_id, NEW.builtdate, NEW.enddate, NEW.ownercat_id, 
			NEW.muni_id, NEW.streetaxis_id,  NEW.postcode, NEW.streetaxis2_id, NEW.postnumber, NEW.postnumber2, NEW.postcomplement, NEW.postcomplement2,
			NEW.descript, NEW.link, NEW.verified, NEW.the_geom,NEW.undelete,NEW.label_x, 
			NEW.label_y, NEW.label_rotation, NEW.expl_id, NEW.publish, NEW.inventory, NEW.uncertain, NEW.num_value);
			
			IF edit_enable_arc_nodes_update_aux IS TRUE THEN
				UPDATE arc SET node_1=NEW.node_1, node_2=NEW.node_2 WHERE arc_id=NEW.arc_id;
			END IF;
				
			IF man_table='man_conduit' THEN
				
				INSERT INTO man_conduit (arc_id) VALUES (NEW.arc_id);
			
			ELSIF man_table='man_siphon' THEN
								
				INSERT INTO man_siphon (arc_id,name) VALUES (NEW.arc_id,NEW.name);
				
			ELSIF man_table='man_waccel' THEN
				
				INSERT INTO man_waccel (arc_id, sander_length,sander_depth,prot_surface,name) 
				VALUES (NEW.arc_id, NEW.sander_length, NEW.sander_depth,NEW.prot_surface,NEW.name);
				
			ELSIF man_table='man_varc' THEN
						
				INSERT INTO man_varc (arc_id) VALUES (NEW.arc_id);
				
			END IF;
							
							
			-- EPA INSERT
        IF (NEW.epa_type = 'CONDUIT') THEN 
            INSERT INTO inp_conduit (arc_id, q0, qmax) VALUES (NEW.arc_id,0,0); 
			
        ELSIF (NEW.epa_type = 'PUMP') THEN 
            INSERT INTO inp_pump (arc_id) VALUES (NEW.arc_id); 
			
		ELSIF (NEW.epa_type = 'ORIFICE') THEN 
            INSERT INTO inp_orifice (arc_id, ori_type) VALUES (NEW.arc_id,'BOTTOM');
			
		ELSIF (NEW.epa_type = 'WEIR') THEN 
            INSERT INTO inp_weir (arc_id, weir_type) VALUES (NEW.arc_id,'SIDEFLOW');
			
		ELSIF (NEW.epa_type = 'OUTLET') THEN 
            INSERT INTO inp_outlet (arc_id, outlet_type) VALUES (NEW.arc_id,'TABULAR/HEAD');
            
		ELSIF (NEW.epa_type = 'VIRTUAL') THEN 
            INSERT INTO inp_virtual (arc_id, add_length) VALUES (NEW.arc_id, false);
				
		END IF;
		
			RETURN NEW;
			   
		ELSIF TG_OP = 'UPDATE' THEN
		
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
			 
				IF (OLD.epa_type = 'CONDUIT') THEN 
				inp_table:= 'inp_conduit';
				ELSIF (OLD.epa_type = 'PUMP') THEN 
				inp_table:= 'inp_pump';
				ELSIF (OLD.epa_type = 'ORIFICE') THEN 
				inp_table:= 'inp_orifice';
				ELSIF (OLD.epa_type = 'WEIR') THEN 
				inp_table:= 'inp_weir';
				ELSIF (OLD.epa_type = 'OUTLET') THEN 
				inp_table:= 'inp_outlet';
				ELSIF (OLD.epa_type = 'VIRTUAL') THEN 
				inp_table:= 'inp_virtual';
				END IF;
				v_sql:= 'DELETE FROM '||inp_table||' WHERE arc_id = '||quote_literal(OLD.arc_id);
				EXECUTE v_sql;
				
				inp_table := NULL;


				IF (NEW.epa_type = 'CONDUIT') THEN 
				inp_table:= 'inp_conduit';
				ELSIF (NEW.epa_type = 'PUMP') THEN 
				inp_table:= 'inp_pump';
				ELSIF (NEW.epa_type = 'ORIFICE') THEN 
				inp_table:= 'inp_orifice';
				ELSIF (NEW.epa_type = 'WEIR') THEN 
				inp_table:= 'inp_weir';
				ELSIF (NEW.epa_type = 'OUTLET') THEN 
				inp_table:= 'inp_outlet';
				ELSIF (NEW.epa_type = 'VIRTUAL') THEN 
				inp_table:= 'inp_virtual';
				END IF;
				v_sql:= 'INSERT INTO '||inp_table||' (arc_id) VALUES ('||quote_literal(NEW.arc_id)||')';
				EXECUTE v_sql;

			END IF;

		 -- UPDATE management values
		IF (NEW.arc_type <> OLD.arc_type) THEN 
			new_man_table:= (SELECT arc_type.man_table FROM arc_type WHERE arc_type.id = NEW.arc_type);
			old_man_table:= (SELECT arc_type.man_table FROM arc_type WHERE arc_type.id = OLD.arc_type);
			IF new_man_table IS NOT NULL THEN
				v_sql:= 'DELETE FROM '||old_man_table||' WHERE arc_id= '||quote_literal(OLD.arc_id);
				EXECUTE v_sql;
				v_sql2:= 'INSERT INTO '||new_man_table||' (arc_id) VALUES ('||quote_literal(NEW.arc_id)||')';
				EXECUTE v_sql2;
			END IF;
		END IF;

			UPDATE arc 
				SET  y1=NEW.y1, y2=NEW.y2, custom_y1=NEW.custom_y1, custom_y2=NEW.custom_y2, elev1=NEW.elev1, elev2=NEW.elev2, custom_elev1=NEW.custom_elev1, custom_elev2=NEW.custom_elev2 , 
				arc_type=NEW.arc_type, arccat_id=NEW.arccat_id, epa_type=NEW.epa_type, sector_id=NEW.sector_id, state_type=NEW.state_type,
				annotation= NEW.annotation, "observ"=NEW.observ,"comment"=NEW.comment, inverted_slope=NEW.inverted_slope, custom_length=NEW.custom_length, dma_id=NEW.dma_id, 
				soilcat_id=NEW.soilcat_id, category_type=NEW.category_type, fluid_type=NEW.fluid_type,location_type=NEW.location_type, workcat_id=NEW.workcat_id, 
				buildercat_id=NEW.buildercat_id, builtdate=NEW.builtdate,ownercat_id=NEW.ownercat_id, 
				muni_id=NEW.muni_id, streetaxis_id=NEW.streetaxis_id,  postcode=NEW.postcode, streetaxis2_id=NEW.streetaxis2_id, postcomplement=NEW.postcomplement, postcomplement2=NEW.postcomplement2,
				postnumber=NEW.postnumber, postnumber2=NEW.postnumber2,  descript=NEW.descript, link=NEW.link, verified=NEW.verified, the_geom=NEW.the_geom, 
				undelete=NEW.undelete,label_x=NEW.label_x,label_y=NEW.label_y, label_rotation=NEW.label_rotation,workcat_id_end=NEW.workcat_id_end,
				code=NEW.code, publish=NEW.publish, inventory=NEW.inventory, enddate=NEW.enddate, uncertain=NEW.uncertain, expl_id=NEW.expl_id
				WHERE arc_id=OLD.arc_id;	
		   
			IF man_table='man_conduit' THEN
								
				UPDATE man_conduit SET arc_id=NEW.arc_id
				WHERE arc_id=OLD.arc_id;
			
			ELSIF man_table='man_siphon' THEN			
								
				UPDATE man_siphon SET  name=NEW.name
				WHERE arc_id=OLD.arc_id;
			
			ELSIF man_table='man_waccel' THEN
							
				UPDATE man_waccel SET  sander_length=NEW.sander_length, sander_depth=NEW.sander_depth, prot_surface=NEW.prot_surface,name=NEW.name
				WHERE arc_id=OLD.arc_id;
			
			ELSIF man_table='man_varc' THEN
								
				UPDATE man_varc SET arc_id=NEW.arc_id
				WHERE arc_id=OLD.arc_id;
			
			END IF;
			
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




	DROP TRIGGER IF EXISTS gw_trg_edit_man_conduit ON "SCHEMA_NAME".v_edit_man_conduit;
	CREATE TRIGGER gw_trg_edit_man_conduit INSTEAD OF INSERT OR DELETE OR UPDATE ON "SCHEMA_NAME".v_edit_man_conduit FOR EACH ROW EXECUTE PROCEDURE "SCHEMA_NAME".gw_trg_edit_man_arc('man_conduit');     

	DROP TRIGGER IF EXISTS gw_trg_edit_man_siphon ON "SCHEMA_NAME".v_edit_man_siphon;
	CREATE TRIGGER gw_trg_edit_man_siphon INSTEAD OF INSERT OR DELETE OR UPDATE ON "SCHEMA_NAME".v_edit_man_siphon FOR EACH ROW EXECUTE PROCEDURE "SCHEMA_NAME".gw_trg_edit_man_arc('man_siphon');   

	DROP TRIGGER IF EXISTS gw_trg_edit_man_waccel ON "SCHEMA_NAME".v_edit_man_waccel;
	CREATE TRIGGER gw_trg_edit_man_waccel INSTEAD OF INSERT OR DELETE OR UPDATE ON "SCHEMA_NAME".v_edit_man_waccel FOR EACH ROW EXECUTE PROCEDURE "SCHEMA_NAME".gw_trg_edit_man_arc('man_waccel'); 

	DROP TRIGGER IF EXISTS gw_trg_edit_man_varc ON "SCHEMA_NAME".v_edit_man_varc;
	CREATE TRIGGER gw_trg_edit_man_varc INSTEAD OF INSERT OR DELETE OR UPDATE ON "SCHEMA_NAME".v_edit_man_varc FOR EACH ROW EXECUTE PROCEDURE "SCHEMA_NAME".gw_trg_edit_man_arc('man_varc'); 
		  