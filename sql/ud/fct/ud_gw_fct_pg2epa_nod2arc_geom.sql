﻿/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


DROP FUNCTION IF EXISTS "ud30".gw_fct_pg2epa_nod2arc_geom(varchar);
CREATE OR REPLACE FUNCTION ud30.gw_fct_pg2epa_nod2arc_geom(result_id_var varchar)  RETURNS integer AS $BODY$
DECLARE
	
record_node ud30.rpt_inp_node%ROWTYPE;
record_arc1 ud30.rpt_inp_arc%ROWTYPE;
record_arc2 ud30.rpt_inp_arc%ROWTYPE;
record_new_arc ud30.rpt_inp_arc%ROWTYPE;
node_diameter double precision;
nodarc_geometry geometry;
nodarc_node_1_geom geometry;
nodarc_node_2_geom geometry;
arc_reduced_geometry geometry;
node_id_aux text;
num_arcs integer;
shortpipe_record record;
to_arc_aux text;
arc_aux text;
node_1_aux text;
node_2_aux text;
geom_aux geometry;
rec_options record;
rec_flowreg record;
counter integer;
old_node_id text;
	
    

BEGIN

--  Search path
    SET search_path = "ud30", public;

--  Looking for parameters
    SELECT * INTO rec_options FROM inp_options;
    counter :=1;
    
--  Move valves to arc
    RAISE NOTICE 'Start loop.....';

    FOR rec_flowreg IN 
	SELECT DISTINCT ON (node_id, exit_conduit) node_id,  exit_conduit, max(flwreg_length) AS flwreg_length, flw_type FROM 
	(SELECT rpt_inp_node.node_id, exit_conduit, flwreg_length, 'ori'::text as flw_type FROM inp_flwreg_orifice JOIN rpt_inp_node ON rpt_inp_node.node_id=inp_flwreg_orifice.node_id JOIN inp_selector_sector ON inp_selector_sector.sector_id=rpt_inp_node.sector_id WHERE result_id=result_id_var
		UNION 
	SELECT DISTINCT rpt_inp_node.node_id,  exit_conduit, flwreg_length, 'out'::text as flw_type FROM inp_flwreg_outlet JOIN rpt_inp_node ON rpt_inp_node.node_id=inp_flwreg_outlet.node_id JOIN inp_selector_sector ON inp_selector_sector.sector_id=rpt_inp_node.sector_id WHERE result_id=result_id_var			
		UNION 
	SELECT DISTINCT rpt_inp_node.node_id,  exit_conduit, flwreg_length, 'pump'::text as flw_type FROM inp_flwreg_pump JOIN rpt_inp_node ON rpt_inp_node.node_id=inp_flwreg_pump.node_id JOIN inp_selector_sector ON inp_selector_sector.sector_id=rpt_inp_node.sector_id WHERE result_id=result_id_var			
		UNION 
	SELECT DISTINCT rpt_inp_node.node_id,  exit_conduit, flwreg_length, 'weir'::text as flw_type FROM inp_flwreg_weir JOIN rpt_inp_node ON rpt_inp_node.node_id=inp_flwreg_weir.node_id JOIN inp_selector_sector ON inp_selector_sector.sector_id=rpt_inp_node.sector_id WHERE result_id=result_id_var)a
	GROUP BY node_id, exit_conduit, flw_type
	ORDER BY node_id
				
	LOOP
		-- Initializing counter
		IF old_node_id IS NULL OR old_node_id!=rec_flowreg.node_id THEN
			counter:=1;
		ELSE
			counter:=counter+1;
		END IF;
	
		-- Getting data from node
		SELECT * INTO record_node FROM rpt_inp_node WHERE node_id = rec_flowreg.node_id AND result_id=result_id_var;
			RAISE NOTICE 'record_node %', record_node;

		-- Getting data from arc
		SELECT arc_id, node_1, node_2, the_geom INTO arc_aux, node_1_aux, node_2_aux, geom_aux FROM rpt_inp_arc WHERE arc_id=rec_flowreg.exit_conduit;
		IF arc_aux IS NULL THEN	
			RAISE NOTICE 'Flow regulator has not an existing exit arc (exit_conduit %) defined on table flowreg for node %', rec_flowreg.exit_conduit, rec_flowreg.node_id;
		ELSE

			IF node_2_aux=rec_flowreg.node_id THEN
				RAISE NOTICE 'The exit arc must be reversed %', arc_aux;
			ELSE 
				-- Create the extrem nodes of the new nodarc
				nodarc_node_1_geom := ST_StartPoint(geom_aux);
				nodarc_node_2_geom := ST_LineInterpolatePoint(geom_aux, rec_flowreg.flwreg_length / ST_Length(geom_aux));

				-- Correct old arc geometry
				arc_reduced_geometry := ST_LineSubstring(geom_aux,ST_LineLocatePoint(geom_aux,nodarc_node_2_geom),1);
				
				IF ST_GeometryType(arc_reduced_geometry) != 'ST_LineString' THEN
						RAISE NOTICE 'arc_id= %, Geom type= %',  record_arc1.arc_id, ST_GeometryType(arc_reduced_geometry);
				END IF;

				UPDATE rpt_inp_arc SET the_geom = arc_reduced_geometry, length=length-rec_flowreg.flwreg_length WHERE arc_id = arc_aux  AND result_id=result_id_var; 

 	    
				-- Create new arc geometry
				nodarc_geometry := ST_MakeLine(nodarc_node_1_geom, nodarc_node_2_geom);

				-- Values to insert into arc table
				record_new_arc.arc_id := concat(node_1_aux,'_',counter,'_a');   
				record_new_arc.flw_code := concat(node_1_aux,'_',rec_flowreg.exit_conduit); 
				record_new_arc.node_1:= record_node.node_1;
				record_new_arc.node_2:= record_node.node_2;  
				record_new_arc.arc_type:= record_node.node_type;
				record_new_arc.arccat_id := record_node.nodecat_id;
				record_new_arc.epa_type := record_node.epa_type;
				record_new_arc.sector_id := record_node.sector_id;
				record_new_arc.state := record_node.state;
				record_new_arc.state_type := record_node.state_type;
				record_new_arc.annotation := record_node.annotation;
				
				-- record_new_arc.length := ST_length2d(nodarc_geometry);
				record_new_arc.the_geom := nodarc_geometry;
      
				-- Inserting new arc into arc table
				RAISE NOTICE 'nodarc_geometry %',nodarc_geometry;
				INSERT INTO rpt_inp_arc (result_id, arc_id, flw_code, node_1, node_2, arc_type, arccat_id, epa_type, sector_id, state, state_type, annotation, length, the_geom)
				VALUES(result_id_var, record_new_arc.arc_id, record_new_arc.flw_code, record_new_arc.node_1, record_new_arc.node_2, record_new_arc.arc_type, record_new_arc.arccat_id, record_new_arc.epa_type, record_new_arc.sector_id, 
				record_new_arc.state, record_new_arc.state_type, record_new_arc.annotation, record_new_arc.length, record_new_arc.the_geom);

				-- Inserting new node into node table
				record_node.epa_type := 'JUNCTION';
				record_node.the_geom := nodarc_node_1_geom;
				record_node.node_id := concat(node_1_aux,'_',counter,'_n');
		
				INSERT INTO rpt_inp_node (result_id, node_id, top_elev, elev, node_type, nodecat_id, epa_type, sector_id, state, state_type, annotation, the_geom) 
				VALUES(result_id_var, record_node.node_id, record_node.top_elev, record_node.elev, record_node.node_type, record_node.nodecat_id, record_node.epa_type, 
						record_node.sector_id, record_node.state, record_node.state_type, record_node.annotation, nodarc_node_2_geom);	
				old_node_id:=rec_flowreg.node_id;
	
			END IF;
		END IF;
    END LOOP;



    RETURN 1;


		
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;