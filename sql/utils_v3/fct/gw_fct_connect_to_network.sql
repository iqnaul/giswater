﻿/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2124

DROP FUNCTION IF EXISTS "SCHEMA_NAME".gw_fct_connect_to_network(character varying[], character varying);



CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_connect_to_network(
    connec_array character varying[],
    feature_type_aux character varying)
  RETURNS void AS
$BODY$

DECLARE
    rec record;
    connect_id_aux  varchar;
    arc_geom       public.geometry;
    candidate_line integer;
    connect_geom   public.geometry;
    link_geom           public.geometry;
    vnode_geom          public.geometry;
    vnode_id_aux   integer;
    link_id_aux   integer;
    arc_id_aux	varchar;
    arcrec record;
    userDefined    boolean;
    sector_aux     integer;
	expl_id_int integer;
	link_id integer;
	state_aux integer;
	dma_aux integer;
	expl_aux integer;
	state_connec integer;
	

	
BEGIN

    -- Search path
    SET search_path = "SCHEMA_NAME", public;

    SELECT * INTO rec FROM config;

    -- Main loop
    IF connec_array IS NOT NULL THEN
	
    
    FOREACH connect_id_aux IN ARRAY connec_array
    LOOP

        -- Control user defined
	SELECT userdefined_geom INTO userDefined FROM link WHERE feature_id = connect_id_aux AND feature_type=feature_type_aux;
	
        IF userDefined IS TRUE THEN
		RAISE NOTICE 'As the value of link on userdefined_geom is true, it is not enabled to modify the link related to the connec % ', connect_id_aux;
	
	ELSE	
		
         	-- Get connec or gully geometry and arc_id  (if it has)
		IF feature_type_aux ='CONNEC' THEN          
			SELECT state, the_geom INTO state_connec, connect_geom FROM connec WHERE connec_id = connect_id_aux;
			SELECT arc_id INTO arc_id_aux FROM connec WHERE connec_id = connect_id_aux;

		ELSIF feature_type_aux ='GULLY' THEN 
			SELECT state, the_geom INTO state_connec, connect_geom FROM gully WHERE gully_id = connect_id_aux;
			SELECT arc_id INTO arc_id_aux FROM gully WHERE gully_id = connect_id_aux;

		END IF;
					
		IF arc_id_aux is null THEN
			-- Improved version for curved lines (not perfect!)
			WITH index_query AS
			(
				SELECT ST_Distance(the_geom, connect_geom) as d, arc_id FROM v_edit_arc ORDER BY the_geom <-> connect_geom LIMIT 10
			)
			SELECT arc_id INTO arc_id_aux FROM index_query ORDER BY d limit 1;
		END IF;
		
		-- Get v_edit_arc geometry
		SELECT * INTO arcrec FROM v_edit_arc WHERE arc_id = arc_id_aux;


		-- Compute link
		IF arcrec.the_geom IS NOT NULL THEN

                 -- Link line
                link_geom := ST_ShortestLine(connect_geom, arcrec.the_geom);

                -- Line end point
                vnode_geom := ST_EndPoint(link_geom);

                -- Delete old link
                SELECT exit_id INTO vnode_id_aux FROM link WHERE feature_id = connect_id_aux AND feature_type=feature_type_aux;
                DELETE FROM vnode WHERE vnode_id=vnode_id_aux ;
                DELETE FROM link WHERE feature_id = connect_id_aux AND feature_type=feature_type_aux;


		--Checking if there is vnode exiting
                SELECT vnode_id INTO vnode_id_aux FROM vnode WHERE ST_DWithin(vnode_geom, vnode.the_geom, rec.node_proximity) LIMIT 1;

                IF vnode_id_aux IS NULL THEN

                        --Get values state, sector, dma, expl_id from arc
			state_aux:= arcrec.state;
			sector_aux:= arcrec.sector_id;
			dma_aux:= arcrec.dma_id;
			expl_aux:= arcrec.expl_id;
			vnode_id_aux := (SELECT nextval('vnode_vnode_id_seq'));

			-- Insert new vnode
			INSERT INTO vnode (vnode_id, vnode_type, state, sector_id, dma_id, expl_id, the_geom) 
			VALUES (vnode_id_aux, 'AUTO',state_aux, sector_aux, dma_aux, expl_aux, vnode_geom);
		END IF;
  

                -- Insert new link
		link_id_aux := (SELECT nextval('link_link_id_seq'));
                
                INSERT INTO link (link_id, the_geom, feature_id, feature_type, exit_id, exit_type, userdefined_geom, state, expl_id) 
                VALUES (link_id_aux, link_geom, connect_id_aux, feature_type_aux, vnode_id_aux, 'VNODE', FALSE, state_connec, arcrec.expl_id);

		-- Update connec or gully arc_id
		IF feature_type_aux ='CONNEC' THEN          
			UPDATE connec SET arc_id=arc_id_aux WHERE connec_id = connect_id_aux;
		ELSIF feature_type_aux ='GULLY' THEN 
			UPDATE connec SET arc_id=arc_id_aux WHERE connec_id = connect_id_aux;
		END IF;
				
            END IF;
            
        END IF;

    END LOOP;

    END IF;

    --PERFORM audit_function(0,2124);
    RETURN;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;