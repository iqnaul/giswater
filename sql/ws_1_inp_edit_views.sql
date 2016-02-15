/*
This file is part of Giswater
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


-- ----------------------------
-- View structure for v_inp_edit
-- ----------------------------


CREATE VIEW "SCHEMA_NAME"."v_edit_inp_junction" AS 
SELECT 
node.node_id, node.elevation, node."depth", node.nodecat_id, node.sector_id, node."state", node.annotation, node.observ, node.comment, node.rotation, node.verified, node.the_geom,
inp_junction.demand, inp_junction.pattern_id
FROM (SCHEMA_NAME.node
JOIN SCHEMA_NAME.inp_junction ON (((inp_junction.node_id)::text = (node.node_id)::text)));



CREATE VIEW "SCHEMA_NAME"."v_edit_inp_reservoir" AS 
SELECT 
node.node_id, node.elevation, node."depth", node.nodecat_id, node.sector_id, node."state", node.annotation, node.observ, node.comment, node.rotation, node.verified, node.the_geom,
inp_reservoir.head, inp_reservoir.pattern_id
FROM (SCHEMA_NAME.node 
JOIN SCHEMA_NAME.inp_reservoir ON (((inp_reservoir.node_id)::text = (node.node_id)::text)));



CREATE VIEW "SCHEMA_NAME"."v_edit_inp_tank" AS 
SELECT 
node.node_id, node.elevation, node."depth", node.nodecat_id, node.sector_id, node."state", node.annotation, node.observ, node.comment, node.rotation, node.verified, node.the_geom,
inp_tank.initlevel, inp_tank.minlevel, inp_tank.maxlevel, inp_tank.diameter, inp_tank.minvol, inp_tank.curve_id
FROM (SCHEMA_NAME.inp_node 
JOIN SCHEMA_NAME.tank ON (((inp_tank.node_id)::text = (node.node_id)::text)));



CREATE VIEW "SCHEMA_NAME"."v_edit_inp_pipe" AS 
SELECT 
arc.arc_id, arc.arccat_id, arc.sector_id, arc."state", arc.annotation, arc.observ, arc.comment, arc.rotation, arc.real_length, arc.verified, arc.the_geom,
inp_pipe.minorloss, inp_pipe.status
FROM (SCHEMA_NAME.arc 
JOIN SCHEMA_NAME.inp_pipe ON (((inp_pipe.arc_id)::text = (arc.arc_id)::text)));



CREATE VIEW "SCHEMA_NAME"."v_edit_inp_pump" AS 
SELECT 
arc.arc_id, arc.arccat_id, arc.sector_id, arc."state", arc.annotation, arc.observ, arc.comment, arc.rotation, arc.real_length, arc.verified, arc.the_geom,
inp_pump.power, inp_pump.curve_id, inp_pump.speed, inp_pump.pattern, inp_pump.status, 
FROM (SCHEMA_NAME.arc 
JOIN SCHEMA_NAME.inp_pump ON (((arc.arc_id)::text = (inp_pump.arc_id)::text)));



CREATE VIEW "SCHEMA_NAME"."v_edit_inp_valve" AS 
SELECT 
arc.arc_id, arc.arccat_id, arc.sector_id, arc."state", arc.annotation, arc.observ, arc.comment, arc.rotation, arc.real_length, arc.verified, arc.the_geom,
inp_valve.valv_type, inp_valve.pressure, inp_valve.flow, inp_valve.coef_loss, inp_valve.curve_id, inp_valve.minorloss, inp_valve.status
FROM (SCHEMA_NAME.arc 
JOIN SCHEMA_NAME.inp_valve ON (((arc.arc_id)::text = (inp_valve.arc_id)::text)));





-----------------------------
-- TRIGGERS EDITING VIEWS FOR NODE
-----------------------------

CREATE OR REPLACE FUNCTION SCHEMA_NAME.v_edit_inp_junction() RETURNS trigger LANGUAGE plpgsql AS $$

	
BEGIN
    
	EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';
		
--	Control insertions ID	
	IF TG_OP = 'INSERT' THEN

--			Node ID
			IF (NEW.node_id IS NULL) THEN
				NEW.node_id := (SELECT nextval('inp_node_id_seq'));
			END IF;
			
--			Node Catalog ID
			IF (NEW.nodecat_id IS NULL) THEN
				IF ((SELECT COUNT(*) FROM cat_node) = 0) THEN
					RAISE EXCEPTION 'There are no nodes catalog defined in the model, define at least one.';
				END IF;			
				NEW.nodecat_id := (SELECT id FROM cat_node LIMIT 1);
			END IF;
			
--			Sector ID
			IF (NEW.sector_id IS NULL) THEN
				IF ((SELECT COUNT(*) FROM sector) = 0) THEN
					RAISE EXCEPTION 'There are no sectors defined in the model, define at least one.';
				END IF;
				NEW.sector_id := (SELECT sector_id FROM sector LIMIT 1);
			END IF;

		INSERT INTO node 		 VALUES (NEW.node_id, NEW.elevation, NEW."depth", NEW.nodecat_id, 'JUNCTION'::text, NEW.sector_id, NEW."state", NEW."state", NEW.annotation, NEW."observ", NEW.rotation, NEW.verified, NEW.the_geom);
		INSERT INTO inp_junction VALUES (NEW.node_id, NEW.demand, NEW.pattern_id);
		RETURN NEW;

	ELSIF TG_OP = 'UPDATE' THEN
		UPDATE node 		SET node_id=NEW.node_id, elevation=NEW.elevation, "depth"=NEW."depth", nodecat_id=NEW.nodecat_id, sector_id=NEW.sector_id, "state"=NEW."state", annotation=NEW.annotation, "observ"=NEW."observ", rotation=NEW.rotation verified=NEW.verified, the_geom=NEW.the_geom, WHERE node_id=OLD.node_id;
		UPDATE inp_junction SET node_id=NEW.node_id, demand=NEW.demand, pattern_id=NEW.pattern_id WHERE node_id=OLD.node_id;
       RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
		DELETE FROM node WHERE node_id=OLD.node_id;
		DELETE FROM inp_junction WHERE node_id=OLD.node_id;
	    RETURN NULL;
    
	END IF;
    RETURN NEW;
END;
$$;




 
CREATE OR REPLACE FUNCTION SCHEMA_NAME.v_edit_inp_reservoir() RETURNS trigger LANGUAGE plpgsql AS $$
	
BEGIN

	EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';
	
--	Control insertions ID	
	IF TG_OP = 'INSERT' THEN
	
--			Node ID
			IF (NEW.node_id IS NULL) THEN
				NEW.node_id := (SELECT nextval('inp_node_id_seq'));
			END IF;
		
--			Node Catalog ID
			IF (NEW.nodecat_id IS NULL) THEN
				IF ((SELECT COUNT(*) FROM cat_node) = 0) THEN
					RAISE EXCEPTION 'There are no nodes catalog defined in the model, define at least one.';
				END IF;			
				NEW.nodecat_id := (SELECT id FROM cat_node LIMIT 1);
			END IF;
			
			
--			Sector ID
			IF (NEW.sector_id IS NULL) THEN
				IF ((SELECT COUNT(*) FROM sector) = 0) THEN
					RAISE EXCEPTION 'There are no sectors defined in the model, define at least one.';
				END IF;
				NEW.sector_id := (SELECT sector_id FROM sector LIMIT 1);
			END IF;
			
		INSERT INTO node 		  VALUES(NEW.node_id, NEW.elevation, NEW."depth", NEW.nodecat_id, 'JUNCTION'::text, NEW.sector_id, NEW."state", NEW."state", NEW.annotation, NEW."observ", NEW.rotation, NEW.verified, NEW.the_geom);
		INSERT INTO inp_reservoir VALUES(NEW.node_id, NEW.head, NEW.pattern_id);
		RETURN NEW;

	ELSIF TG_OP = 'UPDATE' THEN
		UPDATE node 		 SET node_id=NEW.node_id, elevation=NEW.elevation, "depth"=NEW."depth", nodecat_id=NEW.nodecat_id, sector_id=NEW.sector_id, "state"=NEW."state", annotation=NEW.annotation, "observ"=NEW."observ", rotation=NEW.rotation verified=NEW.verified, the_geom=NEW.the_geom, WHERE node_id=OLD.node_id;
		UPDATE inp_reservoir SET node_id=NEW.node_id, head=NEW.head, pattern_id=NEW.pattern_id WHERE node_id=OLD.node_id;
		RETURN NEW;

	ELSIF TG_OP = 'DELETE' THEN
		DELETE FROM node WHERE node_id=OLD.node_id;
		DELETE FROM inp_reservoir WHERE node_id=OLD.node_id;
	    RETURN NULL;
     
	END IF;
    RETURN NEW;
END;
$$;

  
  

CREATE OR REPLACE FUNCTION SCHEMA_NAME.v_edit_inp_tank() RETURNS trigger LANGUAGE plpgsql AS $$
	
BEGIN

	EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';

--	Control insertions ID	
	IF TG_OP = 'INSERT' THEN
	
--			Node ID
			IF (NEW.node_id IS NULL) THEN
				NEW.node_id := (SELECT nextval('inp_node_id_seq'));
			END IF;
			
--			Node Catalog ID
			IF (NEW.nodecat_id IS NULL) THEN
				IF ((SELECT COUNT(*) FROM cat_node) = 0) THEN
					RAISE EXCEPTION 'There are no nodes catalog defined in the model, define at least one.';
				END IF;			
				NEW.nodecat_id := (SELECT id FROM cat_node LIMIT 1);
			END IF;
			

--			Sector ID
			IF (NEW.sector_id IS NULL) THEN
				IF ((SELECT COUNT(*) FROM sector) = 0) THEN
					RAISE EXCEPTION 'There are no sectors defined in the model, define at least one.';
				END IF;
				NEW.sector_id := (SELECT sector_id FROM sector LIMIT 1);
			END IF;

		INSERT INTO node 	 VALUES(NEW.node_id, NEW.elevation, NEW."depth", NEW.nodecat_id, 'JUNCTION'::text, NEW.sector_id, NEW."state", NEW."state", NEW.annotation, NEW."observ", NEW.rotation, NEW.verified, NEW.the_geom);
		INSERT INTO inp_tank VALUES(NEW.node_id,NEW.initlevel,NEW.minlevel,NEW.maxlevel,NEW.diameter,NEW.minvol,NEW.curve_id);
		RETURN NEW;
   
	ELSIF TG_OP = 'UPDATE' THEN
		UPDATE node 	SET node_id=NEW.node_id, elevation=NEW.elevation, "depth"=NEW."depth", nodecat_id=NEW.nodecat_id, sector_id=NEW.sector_id, "state"=NEW."state", annotation=NEW.annotation, "observ"=NEW."observ", rotation=NEW.rotation verified=NEW.verified, the_geom=NEW.the_geom, WHERE node_id=OLD.node_id;
		UPDATE inp_tank SET node_id=NEW.node_id, initlevel=NEW.initlevel, minlevel=NEW.minlevel, maxlevel=NEW.maxlevel, diameter=NEW.diameter, minvol=NEW.minvol, curve_id=NEW.curve_id WHERE node_id=OLD.node_id;
		RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
		DELETE FROM node WHERE node_id=OLD.node_id;
		DELETE FROM inp_tank WHERE node_id=OLD.node_id;
	    RETURN NULL;
		
	END IF;
    RETURN NEW;
END;
$$;



CREATE TRIGGER v_edit_inp_junction INSTEAD OF INSERT OR DELETE OR UPDATE ON "SCHEMA_NAME".v_edit_inp_junction FOR EACH ROW EXECUTE PROCEDURE "SCHEMA_NAME".v_edit_inp_junction();
 
CREATE TRIGGER v_edit_inp_reservoir INSTEAD OF INSERT OR DELETE OR UPDATE ON "SCHEMA_NAME".v_edit_inp_reservoir FOR EACH ROW EXECUTE PROCEDURE "SCHEMA_NAME".v_edit_inp_reservoir();

CREATE TRIGGER v_edit_inp_tank INSTEAD OF INSERT OR DELETE OR UPDATE ON "SCHEMA_NAME".v_edit_inp_tank FOR EACH ROW EXECUTE PROCEDURE "SCHEMA_NAME".v_edit_inp_tank();


  
  
  
  
-----------------------------
-- TRIGGERS EDITING VIEWS FOR ARC
-----------------------------
  

CREATE OR REPLACE FUNCTION SCHEMA_NAME.v_edit_inp_pipe() RETURNS trigger LANGUAGE plpgsql AS $$


BEGIN

	EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';
	
	IF TG_OP = 'INSERT' THEN
--			Arc ID
			IF (NEW.arc_id IS NULL) THEN
				NEW.arc_id := (SELECT nextval('inp_arc_id_seq'));
			END IF;

--			Sector ID
			IF (NEW.sector_id IS NULL) THEN
				IF ((SELECT COUNT(*) FROM sector) = 0) THEN
					RAISE EXCEPTION 'There are no sectors defined in the model, define at least one.';
				END IF;
				NEW.sector_id := (SELECT sector_id FROM sector LIMIT 1);
			END IF;

--			Arc catalog ID
			IF (NEW.arccat_id IS NULL) THEN
				IF ((SELECT COUNT(*) FROM cat_arc) = 0) THEN
					RAISE EXCEPTION 'There are no arcs catalog defined in the model, define at least one.';
				END IF;			
				NEW.arccat_id := (SELECT id FROM cat_arc LIMIT 1);
			END IF;
	
		INSERT INTO arc 	 VALUES (NEW.arc_id, null, null, NEW.arccat_id, 'PIPE'::TEXT, NEW.sector_id, NEW."state", NEW.annotation, NEW."observ", NEW."comment", NEW.rotation, NEW.real_length, NEW.verified, NEW.the_geom);
		INSERT INTO inp_pipe VALUES(NEW.arc_id, NEW.minorloss, NEW.status);
		RETURN NEW;
    
	ELSIF TG_OP = 'UPDATE' THEN
		UPDATE arc 		SET arc_id=NEW.arc_id, arccat_id=NEW.arccat_id, sector_id=NEW.sector_id, "state"=NEW."state", annotation= NEW.annotation, "observ"=NEW."observ", "comment"=NEW."comment", rotation=NEW.rotation, real_length=NEW.real_length, verified=NEW.verified, the_geom=NEW.the_geom WHERE arc_id=OLD.arc_id;
		UPDATE inp_pipe SET arc_id=NEW.arc_id, minorloss=NEW.minorloss, status=NEW.status WHERE arc_id=OLD.arc_id;
		RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
		DELETE FROM arc WHERE arc_id=OLD.arc_id;
		DELETE FROM inp_pipe WHERE arc_id=OLD.arc_id;
	    RETURN NULL;
    
	END IF;
    RETURN NEW;
END;
$$;
  
  

  
  

CREATE OR REPLACE FUNCTION SCHEMA_NAME.v_edit_inp_pump() RETURNS trigger LANGUAGE plpgsql AS $$

	
BEGIN

	EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';

	IF TG_OP = 'INSERT' THEN
--			Arc ID
			IF (NEW.arc_id IS NULL) THEN
				NEW.arc_id := (SELECT nextval('inp_arc_id_seq'));
			END IF;

--			Sector ID
			IF (NEW.sector_id IS NULL) THEN
				IF ((SELECT COUNT(*) FROM sector) = 0) THEN
					RAISE EXCEPTION 'There are no sectors defined in the model, define at least one.';
				END IF;
				NEW.sector_id := (SELECT sector_id FROM sector LIMIT 1);
			END IF;
			
--			Arc catalog ID
			IF (NEW.arccat_id IS NULL) THEN
				IF ((SELECT COUNT(*) FROM cat_arc) = 0) THEN
					RAISE EXCEPTION 'There are no arcs catalog defined in the model, define at least one.';
				END IF;			
				NEW.arccat_id := (SELECT id FROM cat_arc LIMIT 1);
			END IF;
			
		INSERT INTO arc 	 VALUES (NEW.arc_id, null, null, NEW.arccat_id, 'PIPE'::TEXT, NEW.sector_id, NEW."state", NEW.annotation, NEW."observ", NEW."comment", NEW.rotation, NEW.real_length, NEW.verified, NEW.the_geom);
		INSERT INTO inp_pump VALUES (NEW.arc_id, NEW.power, NEW.curve_id, NEW.speed, NEW.pattern, NEW.status);
		RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
		UPDATE arc 		SET arc_id=NEW.arc_id, arccat_id=NEW.arccat_id, sector_id=NEW.sector_id, "state"=NEW."state", annotation= NEW.annotation, "observ"=NEW."observ", "comment"=NEW."comment", rotation=NEW.rotation, real_length=NEW.real_length, verified=NEW.verified, the_geom=NEW.the_geom WHERE arc_id=OLD.arc_id;
		UPDATE inp_pump SET arc_id=NEW.arc_id, power=NEW.power, curve_id=NEW.curve_id, speed=NEW.speed, pattern=NEW.pattern, status=NEW.status WHERE arc_id=OLD.arc_id;
		RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
		DELETE FROM arc WHERE arc_id=OLD.arc_id;
		DELETE FROM inp_pump WHERE arc_id=OLD.arc_id;
	    RETURN NULL;
		
    END IF;
    RETURN NEW;
END;
$$;

 
  

 

CREATE OR REPLACE FUNCTION SCHEMA_NAME.v_edit_inp_valve() RETURNS trigger LANGUAGE plpgsql AS $$


BEGIN

	EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';

    IF TG_OP = 'INSERT' THEN
--			Arc ID
			IF (NEW.arc_id IS NULL) THEN
				NEW.arc_id := (SELECT nextval('inp_arc_id_seq'));
			END IF;

--			Sector ID
			IF (NEW.sector_id IS NULL) THEN
				IF ((SELECT COUNT(*) FROM sector) = 0) THEN
					RAISE EXCEPTION 'There are no sectors defined in the model, define at least one.';
				END IF;
				NEW.sector_id := (SELECT sector_id FROM sector LIMIT 1);
			END IF;

--			Arc catalog ID
			IF (NEW.arccat_id IS NULL) THEN
				IF ((SELECT COUNT(*) FROM cat_arc) = 0) THEN
					RAISE EXCEPTION 'There are no arcs catalog defined in the model, define at least one.';
				END IF;			
				NEW.arccat_id := (SELECT id FROM cat_arc LIMIT 1);
			END IF;
			
		INSERT INTO arc 	  VALUES (NEW.arc_id, null, null, NEW.arccat_id, 'PIPE'::TEXT, NEW.sector_id, NEW."state", NEW.annotation, NEW."observ", NEW."comment", NEW.rotation, NEW.real_length, NEW.verified, NEW.the_geom);
		INSERT INTO inp_valve VALUES (NEW.arc_id, NEW.valv_type, NEW.pressure, NEW.flow, NEW.coef_loss, NEW.curve_id, NEW.minorloss, NEW.status);
		RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
		UPDATE arc 		 SET arc_id=NEW.arc_id, arccat_id=NEW.arccat_id, sector_id=NEW.sector_id, "state"=NEW."state", annotation= NEW.annotation, "observ"=NEW."observ", "comment"=NEW."comment", rotation=NEW.rotation, real_length=NEW.real_length, verified=NEW.verified, the_geom=NEW.the_geom WHERE arc_id=OLD.arc_id;
		UPDATE inp_valve SET arc_id=NEW.arc_id, valv_type=NEW.valv_type, pressure=NEW.pressure, flow=NEW.flow, coef_loss=NEW.coef_loss, curve_id=NEW.curve_id, minorloss=NEW.minorloss, status=NEW.status WHERE arc_id=OLD.arc_id;
		RETURN NEW;
    
	ELSIF TG_OP = 'DELETE' THEN
		DELETE FROM arc WHERE arc_id=OLD.arc_id;
		DELETE FROM inp_valve WHERE arc_id=OLD.arc_id;
	    RETURN NULL;
    
	END IF;
    RETURN NEW;
END;
$$;




CREATE TRIGGER v_edit_inp_pipe INSTEAD OF INSERT OR DELETE OR UPDATE ON "SCHEMA_NAME".v_edit_inp_pipe FOR EACH ROW EXECUTE PROCEDURE "SCHEMA_NAME".v_edit_inp_pipe();

CREATE TRIGGER v_edit_inp_valve INSTEAD OF INSERT OR DELETE OR UPDATE ON "SCHEMA_NAME".v_edit_inp_valve FOR EACH ROW EXECUTE PROCEDURE "SCHEMA_NAME".v_edit_inp_valve();

CREATE TRIGGER v_edit_inp_pump INSTEAD OF INSERT OR DELETE OR UPDATE ON "SCHEMA_NAME".v_edit_inp_pump FOR EACH ROW EXECUTE PROCEDURE "SCHEMA_NAME".v_edit_inp_pump();

   
  
  
   
   
   