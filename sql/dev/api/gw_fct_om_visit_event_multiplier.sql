﻿

DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_om_visit_event_multiplier(visit_id_aux integer);
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_om_visit_event_multiplier(visit_id_aux integer)
  RETURNS geometry[] AS $$
DECLARE
rec_parameter record;
id_last integer;
dma_id_aux integer;
node_id_aux varchar;
rec_node record;
count integer;
array_agg geometry[];



BEGIN


-- hard coded, node & dma

--  Search path
    SET search_path = "SCHEMA_NAME", public;

    count=0;

    -- select attribute of dma
    SELECT dma_id, node.node_id INTO dma_id_aux, node_id_aux FROM node JOIN om_visit_x_node ON om_visit_x_node.node_id=node.node_id 
    WHERE visit_id=visit_id_aux;

    
    -- check if exits multiplier parameter
    IF (SELECT count(*) FROM om_visit_event JOIN om_visit_parameter_x_parameter ON parameter_id=parameter_id1 
    JOIN om_visit_parameter ON parameter_id=om_visit_parameter.id WHERE visit_id=visit_id_aux AND action_type=1 AND feature_type='NODE')>0  THEN


	-- loop for those nodes that has the same dma
	FOR rec_node IN SELECT distinct on (node_id) node.node_id, startdate, node.the_geom FROM node JOIN om_visit_x_node ON om_visit_x_node.node_id=node.node_id JOIN om_visit ON om_visit.id=visit_id
	WHERE dma_id=dma_id_aux AND node.node_id!=node_id_aux 
	LOOP

		count=count+1;
		-- inserting (or update) visits
		IF rec_node.startdate < now()-interval'1 day' THEN
    
			INSERT INTO om_visit (visitcat_id, ext_code, startdate, enddate, user_name, webclient_id, expl_id, descript, is_done)
			SELECT visitcat_id, ext_code, startdate, enddate, user_name, webclient_id, expl_id, descript, is_done
			FROM om_visit WHERE id=visit_id_aux RETURNING id into id_last;
	
			INSERT INTO om_visit_x_node (node_id, visit_id) VALUES (rec_node.node_id, id_last);
		ELSE 
	
			SELECT visit_id INTO id_last FROM om_visit_x_node WHERE node_id=node_id_aux;
		END IF;
		
		-- inserting (or not) parameters
		FOR rec_parameter IN SELECT * FROM om_visit_event JOIN om_visit_parameter_x_parameter ON parameter_id=parameter_id1 
		JOIN om_visit_parameter ON parameter_id=om_visit_parameter.id WHERE visit_id=visit_id_aux AND action_type=1 AND feature_type='NODE'
		LOOP
			IF (SELECT parameter_id FROM om_visit_event WHERE visit_id=id_last AND parameter_id=rec_parameter.parameter_id2) IS NULL THEN
				INSERT INTO om_visit_event (ext_code, visit_id, parameter_id, value, text) VALUES 
				(rec_parameter.ext_code, id_last, rec_parameter.parameter_id2, rec_parameter.value, rec_parameter.text);
			END IF;
		END LOOP;
		array_agg=array_append(array_agg, rec_node.the_geom);
			
	END LOOP;

	UPDATE om_visit_event SET parameter_id= rec_parameter.parameter_id2 WHERE parameter_id=rec_parameter.parameter_id AND visit_id=visit_id_aux;

	
      END IF;

      -- adding the initial node to array
      array_agg=array_append(array_agg, (SELECT the_geom FROM node WHERE node_id=node_id_aux));

RETURN array_agg;
		
END;
$$
  LANGUAGE plpgsql VOLATILE
  COST 100;