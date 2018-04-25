﻿/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 1244

CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_trg_topocontrol_arc()  RETURNS trigger AS
$BODY$

DECLARE 
    nodeRecord1 Record; 
    nodeRecord2 Record;
    optionsRecord Record;
    rec Record;
    sys_elev1_aux double precision;
    sys_elev2_aux double precision;
    y_aux double precision;
    vnoderec Record;
    newPoint public.geometry;    
    connecPoint public.geometry;
    value1 boolean;
    value2 boolean;
    featurecat_aux text;
    state_topocontrol_bool boolean;
    sys_y1_aux double precision;
    sys_y2_aux double precision;
	sys_length_aux double precision;
	is_reversed boolean;
	geom_slp_direction_bool boolean;
	

BEGIN 

    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';

 
 -- Get data from config tables
    SELECT * INTO rec FROM config; 
    SELECT * INTO optionsRecord FROM inp_options LIMIT 1;  
	SELECT value::boolean INTO state_topocontrol_bool FROM config_param_system WHERE parameter='state_topocontrol' ;
	SELECT value::boolean INTO geom_slp_direction_bool FROM config_param_system WHERE parameter='geom_slp_direction' ;
		
	IF state_topocontrol_bool IS FALSE OR state_topocontrol_bool IS NULL THEN

		SELECT * INTO nodeRecord1 FROM node WHERE ST_DWithin(ST_startpoint(NEW.the_geom), node.the_geom, rec.arc_searchnodes)
		ORDER BY ST_Distance(node.the_geom, ST_startpoint(NEW.the_geom)) LIMIT 1;

		SELECT * INTO nodeRecord2 FROM node WHERE ST_DWithin(ST_endpoint(NEW.the_geom), node.the_geom, rec.arc_searchnodes)
		ORDER BY ST_Distance(node.the_geom, ST_endpoint(NEW.the_geom)) LIMIT 1;
       
    ELSIF state_topocontrol_bool IS TRUE THEN
	
		-- Looking for state control
		PERFORM gw_fct_state_control('ARC', NEW.arc_id, NEW.state, TG_OP);
    
		-- Lookig for state=0
		IF NEW.state=0 THEN
			RAISE WARNING 'Topology is not enabled with state=0. The feature will be disconected of the network';
			RETURN NEW;
		END IF;
	
		-- Starting process
		IF TG_OP='INSERT' THEN

			SELECT * INTO nodeRecord1 FROM v_edit_node WHERE ST_DWithin(ST_startpoint(NEW.the_geom), v_edit_node.the_geom, rec.arc_searchnodes)
			AND (NEW.state=1 AND v_edit_node.state=1)
					-- looking for existing nodes that not belongs on the same alternatives that arc
					OR (NEW.state=2 AND v_edit_node.state=1 AND node_id NOT IN 
						(SELECT node_id FROM plan_psector_x_node 
						 WHERE plan_psector_x_node.node_id=v_edit_node.node_id AND state=0 AND psector_id = 
							(SELECT value::integer FROM config_param_user 
							WHERE parameter='psector_vdefault' AND cur_user="current_user"() LIMIT 1 )))
					
					-- looking for planified nodes that belongs on the same alternatives that arc
					OR (NEW.state=2 AND v_edit_node.state=2 AND node_id IN 
						(SELECT node_id FROM plan_psector_x_node 
						 WHERE plan_psector_x_node.node_id=v_edit_node.node_id AND state=1 AND psector_id =
							(SELECT value::integer FROM config_param_user 
							WHERE parameter='psector_vdefault' AND cur_user="current_user"() LIMIT 1)))

					ORDER BY ST_Distance(v_edit_node.the_geom, ST_startpoint(NEW.the_geom)) LIMIT 1;
	
			SELECT * INTO nodeRecord2 FROM v_edit_node WHERE ST_DWithin(ST_endpoint(NEW.the_geom), v_edit_node.the_geom, rec.arc_searchnodes) 
			AND (NEW.state=1 AND v_edit_node.state=1)

					-- looking for existing nodes that not belongs on the same alternatives that arc
					OR (NEW.state=2 AND v_edit_node.state=1 AND node_id NOT IN 
						(SELECT node_id FROM plan_psector_x_node 
						 WHERE plan_psector_x_node.node_id=v_edit_node.node_id AND state=0 AND psector_id = 
							(SELECT value::integer FROM config_param_user 
							WHERE parameter='psector_vdefault' AND cur_user="current_user"() LIMIT 1)))
					
					-- looking for planified nodes that belongs on the same alternatives that arc
					OR (NEW.state=2 AND v_edit_node.state=2 AND node_id IN 
						(SELECT node_id FROM plan_psector_x_node 
						 WHERE plan_psector_x_node.node_id=v_edit_node.node_id AND state=1 AND psector_id =
							(SELECT value::integer FROM config_param_user 
							WHERE parameter='psector_vdefault' AND cur_user="current_user"() LIMIT 1 )))

					ORDER BY ST_Distance(v_edit_node.the_geom, ST_endpoint(NEW.the_geom)) LIMIT 1;

		ELSIF TG_OP='UPDATE' THEN

			SELECT * INTO nodeRecord1 FROM v_edit_node WHERE ST_DWithin(ST_startpoint(NEW.the_geom), v_edit_node.the_geom, rec.arc_searchnodes)
			AND (NEW.state=1 AND v_edit_node.state=1)

					-- looking for existing nodes that not belongs on the same alternatives that arc
					OR (NEW.state=2 AND v_edit_node.state=1 AND node_id NOT IN 
						(SELECT node_id FROM plan_psector_x_node 
						 WHERE plan_psector_x_node.node_id=v_edit_node.node_id AND  state=0 AND psector_id IN 
							(SELECT psector_id FROM plan_psector_x_arc WHERE arc_id=NEW.arc_id)))
							

					-- looking for planified nodes that belongs on the same alternatives that arc
					OR (NEW.state=2 AND v_edit_node.state=2 AND node_id IN 
						(SELECT node_id FROM plan_psector_x_node 
						 WHERE plan_psector_x_node.node_id=v_edit_node.node_id AND  state=1 AND psector_id IN
							(SELECT psector_id FROM plan_psector_x_arc WHERE arc_id=NEW.arc_id)))

					ORDER BY ST_Distance(v_edit_node.the_geom, ST_startpoint(NEW.the_geom)) LIMIT 1;
	
			SELECT * INTO nodeRecord2 FROM v_edit_node WHERE ST_DWithin(ST_endpoint(NEW.the_geom), v_edit_node.the_geom, rec.arc_searchnodes) 
			AND (NEW.state=1 AND v_edit_node.state=1)

					-- looking for existing nodes that not belongs on the same alternatives that arc
					OR (NEW.state=2 AND v_edit_node.state=1 AND node_id NOT IN 
						(SELECT node_id FROM plan_psector_x_node 
						 WHERE plan_psector_x_node.node_id=v_edit_node.node_id AND  state=0 AND psector_id IN 
							(SELECT psector_id FROM plan_psector_x_arc WHERE arc_id=NEW.arc_id)))					

					-- looking for planified nodes that belongs on the same alternatives that arc
					OR (NEW.state=2 AND v_edit_node.state=2 AND node_id IN 
						(SELECT node_id FROM plan_psector_x_node 
						 WHERE plan_psector_x_node.node_id=v_edit_node.node_id AND  state=1 AND psector_id IN
							(SELECT psector_id FROM plan_psector_x_arc WHERE arc_id=NEW.arc_id)))

					ORDER BY ST_Distance(v_edit_node.the_geom, ST_endpoint(NEW.the_geom)) LIMIT 1;
		END IF;
	
    END IF;
	
	--  Control of start/end node
	IF (nodeRecord1.node_id IS NOT NULL) AND (nodeRecord2.node_id IS NOT NULL) THEN	

	-- Control de lineas de longitud 0
		IF (nodeRecord1.node_id = nodeRecord2.node_id) AND (rec.samenode_init_end_control IS TRUE) THEN
			PERFORM audit_function (1040,1244, nodeRecord1.node_id);
            
		ELSE

			-- Calculate system parameters
			is_reversed= FALSE;
			sys_y1_aux:= (CASE WHEN (NEW.custom_y1 IS NOT NULL) THEN NEW.custom_y1::numeric (12,3) ELSE NEW.y1::numeric (12,3) END);
			sys_y2_aux:= (CASE WHEN (NEW.custom_y2 IS NOT NULL) THEN NEW.custom_y2::numeric (12,3) ELSE NEW.y2::numeric (12,3) END);
			sys_elev1_aux:= (CASE WHEN (NEW.custom_elev1 IS NOT NULL) THEN NEW.custom_elev1 ELSE NEW.elev1 END);
			sys_elev2_aux:= (CASE WHEN (NEW.custom_elev2 IS NOT NULL) THEN NEW.custom_elev2 ELSE NEW.elev2 END);
			sys_elev1_aux:= (CASE WHEN sys_elev1_aux IS NOT NULL THEN sys_elev1_aux ELSE (SELECT sys_top_elev FROM v_node WHERE node_id=nodeRecord1.node_id) - (CASE WHEN sys_y1_aux IS NOT NULL THEN sys_y1_aux ELSE 0 END) END);
			sys_elev2_aux:= (CASE WHEN sys_elev2_aux IS NOT NULL THEN sys_elev2_aux ELSE (SELECT sys_top_elev FROM v_node WHERE node_id=nodeRecord2.node_id) - (CASE WHEN sys_y2_aux IS NOT NULL THEN sys_y2_aux ELSE 0 END) END);
		
			-- Update coordinates
			NEW.the_geom := ST_SetPoint(NEW.the_geom, 0, nodeRecord1.the_geom);
			NEW.the_geom := ST_SetPoint(NEW.the_geom, ST_NumPoints(NEW.the_geom) - 1, nodeRecord2.the_geom);
	
			IF ((sys_elev1_aux > sys_elev2_aux) AND (NEW.inverted_slope IS NOT TRUE) OR ((sys_elev1_aux < sys_elev2_aux) AND (NEW.inverted_slope IS TRUE OR geom_slp_direction_bool IS FALSE))) THEN
				NEW.node_1 := nodeRecord1.node_id; 
				NEW.node_2 := nodeRecord2.node_id;
				NEW.sys_elev1 := sys_elev1_aux;
				NEW.sys_elev2 := sys_elev2_aux;

		
			ELSE 
				-- Update conduit direction
				-- Geometry
				NEW.the_geom := ST_reverse(NEW.the_geom);

				-- Node 1 & Node 2
				NEW.node_1 := nodeRecord2.node_id;
				NEW.node_2 := nodeRecord1.node_id;                             
	
				-- Node values
				y_aux := NEW.y1;
				NEW.y1 := NEW.y2;
				NEW.y2 := y_aux;
	
				y_aux := NEW.custom_y1;
				NEW.custom_y1 := NEW.custom_y2;
				NEW.custom_y2 := y_aux;
	
				y_aux := NEW.elev1;
				NEW.elev1 := NEW.elev2;
				NEW.elev2 := y_aux;

				y_aux := NEW.custom_elev1;
				NEW.custom_elev1 := NEW.custom_elev2;
				NEW.custom_elev2 := y_aux;

				NEW.sys_elev1 := sys_elev2_aux;
				NEW.sys_elev2 := sys_elev1_aux;
				is_reversed = TRUE;
						
			END IF;

			NEW.sys_length:= ST_length(NEW.the_geom);
			sys_length_aux:=NEW.sys_length;			
			
			IF NEW.custom_length IS NOT NULL THEN
				sys_length_aux=NEW.custom_length;
			END IF;
			
			IF sys_length_aux < 0.1 THEN 
				sys_length_aux=0.1;
			END IF;

			NEW.sys_slope:= (NEW.sys_elev1-NEW.sys_elev2)/sys_length_aux;
			
			IF NEW.sys_slope > 1 THEN 
				NEW.sys_slope=NULL;
				
			END IF;

		END IF;

		-- Update vnode/link
		IF TG_OP = 'UPDATE' AND is_reversed IS FALSE THEN
			-- Select arcs with start-end on the updated node
			FOR vnoderec IN SELECT * FROM vnode JOIN link ON vnode_id::text=exit_id WHERE exit_type='VNODE' 
			AND ST_DWithin(OLD.the_geom, vnode.the_geom, rec.vnode_update_tolerance)
			LOOP
				-- Update vnode geometry
				NewPoint := ST_LineInterpolatePoint(NEW.the_geom, ST_LineLocatePoint(OLD.the_geom, vnoderec.the_geom));
				UPDATE vnode SET the_geom = newPoint WHERE vnode_id = vnoderec.vnode_id;
			END LOOP; 
		END IF;

		

	-- Check auto insert end nodes
	ELSIF (nodeRecord1.node_id IS NOT NULL) AND (nodeRecord2.node_id IS NULL) AND (SELECT nodeinsert_arcendpoint FROM config) THEN
		IF TG_OP = 'INSERT' THEN
			INSERT INTO node (node_id, sector_id, epa_type, nodecat_id, dma_id, the_geom) 
			VALUES (
            (SELECT nextval('urn_id_seq')),
            (SELECT sector_id FROM sector WHERE (ST_endpoint(NEW.the_geom) @ sector.the_geom) LIMIT 1),
			'JUNCTION'::text,
			(SELECT "value" FROM config_param_user WHERE "parameter"='nodecat_vdefault' AND "cur_user"="current_user"()),
            (SELECT dma_id FROM dma WHERE (ST_endpoint(NEW.the_geom) @ dma.the_geom) LIMIT 1), 
            ST_endpoint(NEW.the_geom)
			);

			INSERT INTO inp_junction (node_id) VALUES ((SELECT currval('urn_id_seq')));
			INSERT INTO man_junction (node_id) VALUES ((SELECT currval('urn_id_seq')));

			-- Update coordinates
			NEW.the_geom:= ST_SetPoint(NEW.the_geom, 0, nodeRecord1.the_geom);
			NEW.node_1:= nodeRecord1.node_id; 
			NEW.node_2:= (SELECT currval('urn_id_seq'));  
			RETURN NEW;
			
		END IF;

	-- Error, no existing nodes
	ELSIF ((nodeRecord1.node_id IS NULL) OR (nodeRecord2.node_id IS NULL)) AND (rec.arc_searchnodes_control IS TRUE) THEN
		PERFORM audit_function (1042,1244,NEW.arc_id);
		
	--Not existing nodes but accepted insertion
	ELSIF ((nodeRecord1.node_id IS NULL) OR (nodeRecord2.node_id IS NULL)) AND (rec.arc_searchnodes_control IS FALSE) THEN
		RETURN NEW;
        
	ELSE
		PERFORM audit_function (1042,1244,NEW.arc_id);
	
	END IF;

RETURN NEW;

END;  
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


DROP TRIGGER IF EXISTS gw_trg_topocontrol_arc ON "SCHEMA_NAME"."arc";

CREATE TRIGGER gw_trg_topocontrol_arc BEFORE INSERT OR UPDATE OF 
the_geom, state, inverted_slope, y1, y2, elev1, elev2, custom_y1, custom_y2, custom_elev1, custom_elev2
ON SCHEMA_NAME.arc FOR EACH ROW  EXECUTE PROCEDURE SCHEMA_NAME.gw_trg_topocontrol_arc();
