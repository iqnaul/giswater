/*
This file is part of Giswater 2.0
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

SET search_path = "SCHEMA_NAME", public, pg_catalog;



-- ----------------------------
-- Sequence structure
-- ----------------------------

CREATE SEQUENCE "inp_backdrop_id_seq" 
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE "inp_controls_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE "inp_curve_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE "inp_demand_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE "inp_labels_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE "inp_pattern_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE "inp_rules_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE "inp_sector_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE "inp_vertice_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE "rpt_arc_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE "rpt_energy_usage_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE "rpt_hydraulic_status_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE "rpt_node_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


CREATE SEQUENCE "rpt_cat_result_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


CREATE SEQUENCE "temp_node_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE "temp_arc_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



-- ----------------------------
-- Table structure INP temporal
-- ----------------------------


CREATE TABLE temp_node
(
  node_id character varying(16) NOT NULL,
  elevation numeric(12,4),
  depth numeric(12,4),
  node_type character varying(30),
  nodecat_id character varying(30),
  epa_type character varying(16),
  sector_id character varying(30),
  state character varying(16),
  annotation character varying(254),
  observ character varying(254),
  comment character varying(254),
  dma_id character varying(30),
  soilcat_id character varying(16),
  category_type character varying(18),
  fluid_type character varying(18),
  location_type character varying(18),
  workcat_id character varying(255),
  buildercat_id character varying(30),
  builtdate date,
  ownercat_id character varying(30),
  adress_01 character varying(50),
  adress_02 character varying(50),
  adress_03 character varying(50),
  descript character varying(254),
  rotation numeric(6,3),
  link character varying(512),
  verified character varying(16),
  the_geom public.geometry (POINT, SRID_VALUE),
  undelete boolean,
  workcat_id_end character varying(255),
  label_x character varying(30),
  label_y character varying(30),
  label_rotation numeric(6,3),
  CONSTRAINT temp_node_pkey PRIMARY KEY (node_id)
)
;


CREATE TABLE temp_arc
(
  arc_id character varying(16) NOT NULL,
  node_1 character varying(16),
  node_2 character varying(16),
  arccat_id character varying(30),
  epa_type character varying(16),
  sector_id character varying(30),
  state character varying(16),
  annotation character varying(254),
  observ character varying(254),
  comment character varying(254),
  custom_length numeric(12,2),
  dma_id character varying(30),
  soilcat_id character varying(16),
  category_type character varying(18),
  fluid_type character varying(18),
  location_type character varying(18),
  workcat_id character varying(255),
  buildercat_id character varying(30),
  builtdate date,
  ownercat_id character varying(30),
  adress_01 character varying(50),
  adress_02 character varying(50),
  adress_03 character varying(50),
  descript character varying(254),
  rotation numeric(6,3),
  link character varying(512),
  verified character varying(16),
  the_geom public.geometry (LINESTRING, SRID_VALUE),
  undelete boolean,
  workcat_id_end character varying(255),
  label_x character varying(30),
  label_y character varying(30),
  label_rotation numeric(6,3),
  CONSTRAINT temp_arc_pkey PRIMARY KEY (arc_id));


-- ----------------------------
-- Table structure INP
-- ----------------------------


CREATE TABLE "inp_arc_type" (
"id" varchar(16)   NOT NULL,
CONSTRAINT inp_arc_type_pkey PRIMARY KEY (id)
);


CREATE TABLE "inp_node_type" (
"id" varchar(16)   NOT NULL,
CONSTRAINT inp_node_type_pkey PRIMARY KEY (id)
);


CREATE TABLE "inp_cat_mat_roughness" (
  id serial NOT NULL,
  matcat_id character varying(30) NOT NULL,
  period_id character varying(30),
  init_age integer,
  end_age integer,
  roughness numeric(12,4),
  descript text,
  CONSTRAINT inp_cat_mat_roughness_pkey PRIMARY KEY (id)
);



CREATE TABLE "inp_giswater_config" (
"id" varchar(16) NOT NULL,
"giswater_file_path" text,
"giswater_software_path" text,
"inp_file_path" text,
"rpt_file_path" text,
"rpt_result_id" text,
CONSTRAINT inp_giswater_config_pkey PRIMARY KEY (id)
);



CREATE TABLE "inp_backdrop" (
"id" int4 DEFAULT nextval('"SCHEMA_NAME".inp_backdrop_id_seq'::regclass) NOT NULL,
"text" varchar(254)  
);


CREATE TABLE "inp_controls" (
"id" int4 DEFAULT nextval('"SCHEMA_NAME".inp_controls_id_seq'::regclass) NOT NULL,
"text" varchar(254)  
);


CREATE TABLE "inp_curve" (
"id" int4 DEFAULT nextval('"SCHEMA_NAME".inp_curve_id_seq'::regclass) NOT NULL,
"curve_id" varchar(16)   NOT NULL,
"x_value" numeric(12,4),
"y_value" numeric(12,4),
CONSTRAINT inp_curve_pkey PRIMARY KEY (id)
);


CREATE TABLE "inp_curve_id" (
"id" varchar(16)   NOT NULL,
"curve_type" varchar(20)  
);


CREATE TABLE "inp_demand" (
"id" int4 DEFAULT nextval('"SCHEMA_NAME".inp_demand_id_seq'::regclass) NOT NULL,
"node_id" varchar(16)   NOT NULL,
"demand" numeric(12,6),
"pattern_id" varchar(16)  ,
"deman_type" varchar(18)  
);


CREATE TABLE "inp_emitter" (
"node_id" varchar(16)   NOT NULL,
"coef" numeric
);


CREATE TABLE "inp_energy_el" (
"id" int4 NOT NULL,
"pump_id" varchar(16)  ,
"parameter" varchar(20)  ,
"value" varchar(30)  ,
CONSTRAINT inp_energy_el_pkey PRIMARY KEY (id)
);


CREATE TABLE "inp_energy_gl" (
"id" int4 NOT NULL,
"energ_type" varchar(18)  ,
"parameter" varchar(20)  ,
"value" varchar(30)  ,
CONSTRAINT inp_energy_gl_pkey PRIMARY KEY (id)
);


CREATE TABLE "inp_junction" (
"node_id" varchar(16)   NOT NULL,
"demand" numeric(12,6),
"pattern_id" varchar(16)  
);


CREATE TABLE "inp_label" (
"id" int4 DEFAULT nextval('"SCHEMA_NAME".inp_labels_id_seq'::regclass) NOT NULL,
"xcoord" numeric(18,6),
"ycoord" numeric(18,6),
"label" varchar(50)  ,
"node_id" varchar(16)  
);


CREATE TABLE "inp_mixing" (
"node_id" varchar(16)   NOT NULL,
"mix_type" varchar(18)  ,
"value" numeric
);


CREATE TABLE "inp_options" (
"units" varchar(20)   NOT NULL,
"headloss" varchar(20)  ,
"hydraulics" varchar(12)  ,
"specific_gravity" numeric(12,6),
"viscosity" numeric(12,6),
"trials" numeric(12,6),
"accuracy" numeric(12,6),
"unbalanced" varchar(12)  ,
"checkfreq" numeric(12,6),
"maxcheck" numeric(12,6),
"damplimit" numeric(12,6),
"pattern" varchar(16)  ,
"demand_multiplier" numeric(12,6),
"emitter_exponent" numeric(12,6),
"quality" varchar(18)  ,
"diffusivity" numeric(12,6),
"tolerance" numeric(12,6),
"hydraulics_fname" varchar(254)  ,
"unbalanced_n" numeric(12,6),
"node_id" varchar(16)  
);


CREATE TABLE "inp_pattern" (
"id" int4 DEFAULT nextval('"SCHEMA_NAME".inp_pattern_id_seq'::regclass) NOT NULL,
"pattern_id" varchar(16)   NOT NULL,
"factor_1" numeric(12,4),
"factor_2" numeric(12,4),
"factor_3" numeric(12,4),
"factor_4" numeric(12,4),
"factor_5" numeric(12,4),
"factor_6" numeric(12,4),
"factor_7" numeric(12,4),
"factor_8" numeric(12,4),
"factor_9" numeric(12,4),
"factor_10" numeric(12,4),
"factor_11" numeric(12,4),
"factor_12" numeric(12,4),
"factor_13" numeric(12,4),
"factor_14" numeric(12,4),
"factor_15" numeric(12,4),
"factor_16" numeric(12,4),
"factor_17" numeric(12,4),
"factor_18" numeric(12,4),
"factor_19" numeric(12,4),
"factor_20" numeric(12,4),
"factor_21" numeric(12,4),
"factor_22" numeric(12,4),
"factor_23" numeric(12,4),
"factor_24" numeric(12,4)
);


CREATE TABLE "inp_pipe" (
"arc_id" varchar(16)   NOT NULL,
"minorloss" numeric(12,6),
"status" varchar(12),
"custom_roughness" numeric(12,4),  
"custom_dint" numeric(12,3)
);


CREATE TABLE "inp_shortpipe" (
"node_id" varchar(16)   NOT NULL,
"minorloss" numeric(12,6),
"to_arc" varchar(16)  ,
"status" varchar(12)  ,
CONSTRAINT inp_shortpipe_pkey PRIMARY KEY (node_id)
);


CREATE TABLE "inp_project_id" (
"title" varchar(254)  ,
"author" varchar(50)  ,
"date" varchar(12)  
);


CREATE TABLE "inp_pump" (
"node_id" varchar(16)   NOT NULL,
"power" varchar  ,
"curve_id" varchar  ,
"speed" numeric(12,6),
"pattern" varchar  ,
"status" varchar(12),
"to_arc" varchar(16)
);


CREATE TABLE "inp_quality" (
"node_id" varchar(16)   NOT NULL,
"initqual" numeric
);


CREATE TABLE "inp_reactions_el" (
"id" int4 NOT NULL,
"parameter" varchar(20)   NOT NULL,
"arc_id" varchar(16)  ,
"value" numeric,
CONSTRAINT inp_reactions_el_pkey PRIMARY KEY (id)

);


CREATE TABLE "inp_reactions_gl" (
"id" int4 NOT NULL,
"react_type" varchar(30)   NOT NULL,
"parameter" varchar(20)  ,
"value" numeric,
CONSTRAINT inp_reactions_gl_pkey PRIMARY KEY (id)
);


CREATE TABLE "inp_report" (
"pagesize" numeric NOT NULL,
"file" varchar(254)  ,
"status" varchar(4)  ,
"summary" varchar(3)  ,
"energy" varchar(3)  ,
"nodes" varchar(254)  ,
"links" varchar(254)  ,
"elevation" varchar(16)  ,
"demand" varchar(16)  ,
"head" varchar(16)  ,
"pressure" varchar(16)  ,
"quality" varchar(16)  ,
"length" varchar(16)  ,
"diameter" varchar(16)  ,
"flow" varchar(16)  ,
"velocity" varchar(16)  ,
"headloss" varchar(16)  ,
"setting" varchar(16)  ,
"reaction" varchar(16)  ,
"f_factor" varchar(16)  
);


CREATE TABLE "inp_reservoir" (
"node_id" varchar(16)   NOT NULL,
"head" numeric(12,4),
"pattern_id" varchar(16)  
);


CREATE TABLE "inp_rules" (
"id" int4 DEFAULT nextval('"SCHEMA_NAME".inp_rules_id_seq'::regclass) NOT NULL,
"text" varchar(254)  
);


CREATE TABLE "inp_source" (
"node_id" varchar(16)   NOT NULL,
"sourc_type" varchar(18)  ,
"quality" numeric(12,6),
"pattern_id" varchar(16)  
);


CREATE TABLE "inp_tags" (
"object" varchar(18)  ,
"node_id" varchar(16)   NOT NULL,
"tag" varchar(50)  
);


CREATE TABLE "inp_tank" (
"node_id" varchar(16)   NOT NULL,
"initlevel" numeric(12,4),
"minlevel" numeric(12,4),
"maxlevel" numeric(12,4),
"diameter" numeric(12,4),
"minvol" numeric(12,4),
"curve_id" varchar(16)
);


CREATE TABLE "inp_times" (
"duration" varchar(10)   NOT NULL,
"hydraulic_timestep" varchar(10)  ,
"quality_timestep" varchar(10)  ,
"rule_timestep" varchar(10)  ,
"pattern_timestep" varchar(10)  ,
"pattern_start" varchar(10)  ,
"report_timestep" varchar(10)  ,
"report_start" varchar(10)  ,
"start_clocktime" varchar(10)  ,
"statistic" varchar(18)  
);


CREATE TABLE "inp_valve" (
"node_id" varchar(16)   NOT NULL,
"valv_type" varchar(18)  ,
"pressure" numeric(12,4),
"diameter" numeric(12,4),
"flow" numeric(12,4),
"coef_loss" numeric(12,4),
"curve_id" int4,
"minorloss" numeric(12,4),
"status" varchar(12),
"to_arc" varchar(16)
);



CREATE TABLE "inp_typevalue_energy" (
"id" varchar(18)   NOT NULL
);


CREATE TABLE "inp_typevalue_pump" (
"id" varchar(18)   NOT NULL
);


CREATE TABLE "inp_typevalue_reactions_gl" (
"id" varchar(30)   NOT NULL
);


CREATE TABLE "inp_typevalue_source" (
"id" varchar(18)   NOT NULL
);


CREATE TABLE "inp_typevalue_valve" (
"id" varchar(18)   NOT NULL,
"descript" varchar(50)  ,
"meter" varchar(18)  
);


CREATE TABLE "inp_value_ampm" (
"id" varchar(18)   NOT NULL
);


CREATE TABLE "inp_value_curve" (
"id" varchar(18)   NOT NULL
);


CREATE TABLE "inp_value_mixing" (
"id" varchar(18)   NOT NULL
);


CREATE TABLE "inp_value_noneall" (
"id" varchar(18)   NOT NULL
);


CREATE TABLE "inp_value_opti_headloss" (
"id" varchar(18)   NOT NULL
);


CREATE TABLE "inp_value_opti_hyd" (
"id" varchar(20)   NOT NULL
);


CREATE TABLE "inp_value_opti_qual" (
"id" varchar(18)   NOT NULL
);



CREATE TABLE "inp_value_opti_unbal" (
"id" varchar(20)   NOT NULL
);


CREATE TABLE "inp_value_opti_units" (
"id" varchar(18)   NOT NULL
);


CREATE TABLE "inp_value_param_energy" (
"id" varchar(18)   NOT NULL
);


CREATE TABLE "inp_value_reactions_el" (
"id" varchar(18)   NOT NULL
);


CREATE TABLE "inp_value_reactions_gl" (
"id" varchar(18)   NOT NULL
);


CREATE TABLE "inp_value_status_pipe" (
"id" varchar(18)   NOT NULL,
CONSTRAINT inp_value_status_pipe_pkey PRIMARY KEY (id)
);


CREATE TABLE "inp_value_status_pump" (
"id" varchar(18)   NOT NULL,
CONSTRAINT inp_value_status_pump_pkey PRIMARY KEY (id)
);


CREATE TABLE "inp_value_status_valve" (
"id" varchar(18)   NOT NULL,
CONSTRAINT inp_value_status_valve_pkey PRIMARY KEY (id)
);

CREATE TABLE "inp_value_times" (
"id" varchar(18)   NOT NULL
);


CREATE TABLE "inp_value_yesno" (
"id" varchar(3)   NOT NULL
);


CREATE TABLE "inp_value_yesnofull" (
"id" varchar(18)   NOT NULL
);


CREATE TABLE "inp_value_plan" (
"id" varchar(16)   NOT NULL,
"observ" varchar(254)  

);


-- ----------------------------
-- Table structure for rpt
-- ----------------------------

CREATE TABLE "rpt_arc" (
"id" int4 DEFAULT nextval('"SCHEMA_NAME".rpt_arc_id_seq'::regclass) NOT NULL,
"result_id" varchar(16)   NOT NULL,
"arc_id" varchar(16)  ,
"length" numeric,
"diameter" numeric,
"flow" numeric,
"vel" numeric,
"headloss" numeric,
"setting" numeric,
"reaction" numeric,
"ffactor" numeric,
"other" varchar(100)  ,
"time" varchar(100)  ,
"status" varchar(16)  
);



CREATE TABLE "rpt_energy_usage" (
"id" int4 DEFAULT nextval('"SCHEMA_NAME".rpt_energy_usage_id_seq'::regclass) NOT NULL,
"result_id" varchar(16)   NOT NULL,
"nodarc_id" varchar(16),
"usage_fact" numeric,
"avg_effic" numeric,
"kwhr_mgal" numeric,
"avg_kw" numeric,
"peak_kw" numeric,
"cost_day" numeric
);


CREATE TABLE "rpt_hydraulic_status" (
"id" int4 DEFAULT nextval('"SCHEMA_NAME".rpt_hydraulic_status_id_seq'::regclass) NOT NULL,
"result_id" varchar(16)   NOT NULL,
"time" varchar(10)  ,
"text" varchar(100)  
);


CREATE TABLE "rpt_node" (
"id" int4 DEFAULT nextval('"SCHEMA_NAME".rpt_node_id_seq'::regclass) NOT NULL,
"result_id" varchar(16)   NOT NULL,
"node_id" varchar(16)   NOT NULL,
"elevation" numeric,
"demand" numeric,
"head" numeric,
"press" numeric,
"other" varchar(100)  ,
"time" varchar(100)  ,
"quality" numeric(12,4)
);


CREATE TABLE "rpt_cat_result" (
"id" int4 DEFAULT nextval('"SCHEMA_NAME".rpt_cat_result_id_seq'::regclass) NOT NULL,
"result_id" varchar(16)   NOT NULL,
"n_junction" numeric,
"n_reservoir" numeric,
"n_tank" numeric,
"n_pipe" numeric,
"n_pump" numeric,
"n_valve" numeric,
"head_form" text ,
"hydra_time" text  ,
"hydra_acc" numeric,
"st_ch_freq" numeric,
"max_tr_ch" numeric,
"dam_li_thr" numeric,
"max_trials" numeric,
"q_analysis" varchar(20)  ,
"spec_grav" numeric,
"r_kin_visc" numeric,
"r_che_diff" numeric,
"dem_multi" numeric,
"total_dura" text,
"exec_date" timestamp(6) DEFAULT now(),
"q_timestep" varchar(16)  ,
"q_tolerance" varchar(16)  
);



-- ----------------------------
-- Table structure for SELECTORS
-- ----------------------------

CREATE TABLE "rpt_selector_result" (
"id" serial NOT NULL, 
"result_id" varchar(16)   NOT NULL,
"cur_user" text
);

CREATE TABLE "rpt_selector_compare" (
"id" serial NOT NULL,
"result_id" varchar(16)   NOT NULL,
"cur_user" text
);

CREATE TABLE "inp_selector_sector" (
"sector_id" varchar(30)   NOT NULL
);


CREATE TABLE "inp_selector_state" (
"id" varchar(16)   NOT NULL,
"observ" varchar(254)  ,
CONSTRAINT inp_selector_state_pkey PRIMARY KEY (id)
);



-- ----------------------------
-- Primary Key structure
-- ----------------------------

ALTER TABLE "inp_backdrop" ADD PRIMARY KEY ("id");
ALTER TABLE "inp_controls" ADD PRIMARY KEY ("id");
ALTER TABLE "inp_curve_id" ADD PRIMARY KEY ("id");
ALTER TABLE "inp_demand" ADD PRIMARY KEY ("id");
ALTER TABLE "inp_emitter" ADD PRIMARY KEY ("node_id");
ALTER TABLE "inp_junction" ADD PRIMARY KEY ("node_id");
ALTER TABLE "inp_label" ADD PRIMARY KEY ("id");
ALTER TABLE "inp_mixing" ADD PRIMARY KEY ("node_id");
ALTER TABLE "inp_options" ADD PRIMARY KEY ("units");
ALTER TABLE "inp_pattern" ADD PRIMARY KEY ("id");
ALTER TABLE "inp_pipe" ADD PRIMARY KEY ("arc_id");
ALTER TABLE "inp_project_id" ADD PRIMARY KEY ("title");
ALTER TABLE "inp_pump" ADD PRIMARY KEY ("node_id");
ALTER TABLE "inp_quality" ADD PRIMARY KEY ("node_id");
ALTER TABLE "inp_report" ADD PRIMARY KEY ("pagesize");
ALTER TABLE "inp_reservoir" ADD PRIMARY KEY ("node_id");
ALTER TABLE "inp_rules" ADD PRIMARY KEY ("id");
ALTER TABLE "inp_source" ADD PRIMARY KEY ("node_id");
ALTER TABLE "inp_tags" ADD PRIMARY KEY ("node_id");
ALTER TABLE "inp_tank" ADD PRIMARY KEY ("node_id");
ALTER TABLE "inp_times" ADD PRIMARY KEY ("duration");
ALTER TABLE "inp_typevalue_energy" ADD PRIMARY KEY ("id");
ALTER TABLE "inp_typevalue_pump" ADD PRIMARY KEY ("id");
ALTER TABLE "inp_typevalue_reactions_gl" ADD PRIMARY KEY ("id");
ALTER TABLE "inp_typevalue_source" ADD PRIMARY KEY ("id");
ALTER TABLE "inp_typevalue_valve" ADD PRIMARY KEY ("id");
ALTER TABLE "inp_value_ampm" ADD PRIMARY KEY ("id");
ALTER TABLE "inp_value_curve" ADD PRIMARY KEY ("id");
ALTER TABLE "inp_value_mixing" ADD PRIMARY KEY ("id");
ALTER TABLE "inp_value_noneall" ADD PRIMARY KEY ("id");
ALTER TABLE "inp_value_opti_headloss" ADD PRIMARY KEY ("id");
ALTER TABLE "inp_value_opti_hyd" ADD PRIMARY KEY ("id");
ALTER TABLE "inp_value_opti_qual" ADD PRIMARY KEY ("id");
ALTER TABLE "inp_value_opti_unbal" ADD PRIMARY KEY ("id");
ALTER TABLE "inp_value_opti_units" ADD PRIMARY KEY ("id");
ALTER TABLE "inp_value_param_energy" ADD PRIMARY KEY ("id");
ALTER TABLE "inp_value_reactions_el" ADD PRIMARY KEY ("id");
ALTER TABLE "inp_value_reactions_gl" ADD PRIMARY KEY ("id");
ALTER TABLE "inp_value_times" ADD PRIMARY KEY ("id");
ALTER TABLE "inp_value_yesno" ADD PRIMARY KEY ("id");
ALTER TABLE "inp_value_yesnofull" ADD PRIMARY KEY ("id");
ALTER TABLE "inp_valve" ADD PRIMARY KEY ("node_id");
ALTER TABLE "rpt_selector_result" ADD PRIMARY KEY ("id");
ALTER TABLE "rpt_selector_compare" ADD PRIMARY KEY ("id");
ALTER TABLE "rpt_cat_result" ADD PRIMARY KEY ("result_id");
ALTER TABLE "rpt_arc" ADD PRIMARY KEY ("id");
ALTER TABLE "rpt_energy_usage" ADD PRIMARY KEY ("id");
ALTER TABLE "rpt_hydraulic_status" ADD PRIMARY KEY ("id");
ALTER TABLE "rpt_node" ADD PRIMARY KEY ("id");
ALTER TABLE "inp_selector_sector" ADD PRIMARY KEY ("sector_id");



CREATE INDEX temp_arc_index ON temp_arc USING GIST (the_geom);
CREATE INDEX temp_node_index ON temp_node USING GIST (the_geom);

