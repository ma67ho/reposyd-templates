CREATE TABLE da_analysis_definition ( 
	uuid                 char(38) NOT NULL  PRIMARY KEY  ,
	project              char(38) NOT NULL    ,
	name                 varchar(255)     ,
	description          text     ,
	[type]               varchar(100)     ,
	repository           char(38) NOT NULL    ,
	properties           text     
 );

CREATE TABLE dd_attribute_history ( 
	dda                  char(38) NOT NULL    ,
	ddo                  char(38) NOT NULL    ,
	ddo_revision         integer NOT NULL    ,
	value                blob     ,
	timestamp            datetime     ,
	flag_modified        boolean     
 );

CREATE INDEX Idx_dd_attribute_history_ddo ON dd_attribute_history ( ddo, ddo_revision );

CREATE TABLE dd_ddl_solution_history ( 
	solution             char(38) NOT NULL    ,
	ddl                  char(38) NOT NULL    ,
	leftFrom             integer     ,
	leftTo               integer     ,
	rightFrom            integer     ,
	rightTo              integer     ,
	revision             integer     ,
	acceptedBy           char(38)     ,
	acceptedRevisionLeft integer  DEFAULT -1   ,
	acceptedRevisionRight integer  DEFAULT -1   ,
	acceptedState        varchar(100)     ,
	modifiedBy           char(38)     ,
	timestamp            datetime  DEFAULT CURRENT_TIMESTAMP   
 );

CREATE INDEX idx_dd_variant_ddl_solution_0 ON dd_ddl_solution_history ( solution );

CREATE INDEX idx_dd_variant_ddl_dd_link_0 ON dd_ddl_solution_history ( ddl );

CREATE TABLE dd_link_history ( 
	uuid                 char(38) NOT NULL    ,
	definition           char(38) NOT NULL    ,
	do_left              char(38) NOT NULL    ,
	do_right             char(38) NOT NULL    ,
	cm_modified_by       char(38) NOT NULL    ,
	cm_timestamp         datetime  DEFAULT CURRENT_TIMESTAMP   ,
	repository           char(38) NOT NULL    
 );

CREATE INDEX idx_dd_link_definition_1 ON dd_link_history ( definition );

CREATE INDEX idx_dd_link_source_1 ON dd_link_history ( do_left );

CREATE INDEX idx_dd_link_target_1 ON dd_link_history ( do_right );

CREATE INDEX idx_dd_link_2 ON dd_link_history ( cm_modified_by );

CREATE INDEX id_dd_link_history ON dd_link_history ( uuid );

CREATE TABLE dd_object_history ( 
	uuid                 char(38) NOT NULL    ,
	definition           char(38)     ,
	localId              integer     ,
	masterId             integer     ,
	cm_revision          integer     ,
	cm_modified_by       char(38)     ,
	created              datetime  DEFAULT CURRENT_TIMESTAMP   ,
	cm_timestamp         datetime     ,
	repository           char(38)     ,
	CONSTRAINT pk_dd_history UNIQUE ( uuid, cm_revision ) ,
	CONSTRAINT Unq_dd_object_history_uuid UNIQUE ( uuid, cm_revision ) 
 );

CREATE INDEX idx_dd_object_history_uuid ON dd_object_history ( uuid );

CREATE TABLE dm_diagram ( 
	uuid                 char  NOT NULL  PRIMARY KEY  ,
	solution             char      ,
	name                 varchar(255)     ,
	ddo                  char(38)     ,
	[type]               char(255)     ,
	properties           text     ,
	cm_revision          integer  DEFAULT 0   ,
	cm_modified_by       char(38)     ,
	cm_timestamp         datetime  DEFAULT CURRENT_TIMESTAMP   ,
	cm_deleted           boolean  DEFAULT 0   ,
	repository           char  NOT NULL    ,
	CONSTRAINT unq_dm_diagram UNIQUE ( ddo, [type] ) 
 );

CREATE INDEX idx_dm_diagram_solution ON dm_diagram ( solution, ddo );

CREATE TABLE dm_diagram_history ( 
	uuid                 char  NOT NULL    ,
	solution             char      ,
	name                 varchar(255)     ,
	ddo                  char(38)     ,
	[type]               char(255)     ,
	properties           text     ,
	cm_revision          integer  DEFAULT 0   ,
	cm_modified_by       char(38)     ,
	cm_timestamp         datetime  DEFAULT CURRENT_TIMESTAMP   ,
	cm_deleted           boolean  DEFAULT 0   ,
	repository           char  NOT NULL    
 );

CREATE TABLE dm_item ( 
	uuid                 char(38) NOT NULL  PRIMARY KEY  ,
	diagram              char(38) NOT NULL    ,
	[type]               varchar(255)     ,
	properties           text  DEFAULT '{}'   ,
	ddoddl               char(38)     ,
	revision_from        integer  DEFAULT 0   ,
	revision_to          integer  DEFAULT -1   ,
	ghost                boolean  DEFAULT 0   ,
	cm_modified_by       char(38) NOT NULL    ,
	cm_revision          integer NOT NULL DEFAULT 0   ,
	cm_timestamp         datetime     ,
	repository           char(38) NOT NULL    ,
	CONSTRAINT Unq_dm_item_uuid UNIQUE ( uuid, cm_revision ) ,
	FOREIGN KEY ( diagram ) REFERENCES dm_diagram( uuid ) ON DELETE CASCADE 
 );

CREATE INDEX idx_dm_shape ON dm_item ( diagram );

CREATE INDEX idx_dm_shape_ddoddl ON dm_item ( ddoddl );

CREATE TABLE dm_item_history ( 
	uuid                 char(38) NOT NULL    ,
	diagram              char(38) NOT NULL    ,
	[type]               varchar(255)     ,
	properties           text  DEFAULT '{}'   ,
	ddoddl               char(38)     ,
	revision_from        integer  DEFAULT 0   ,
	revision_to          integer  DEFAULT -1   ,
	ghost                boolean  DEFAULT 0   ,
	cm_modified_by       char(38) NOT NULL    ,
	cm_revision          integer NOT NULL DEFAULT 0   ,
	cm_timestamp         datetime     ,
	repository           char(38) NOT NULL    
 );

CREATE INDEX idx_dm_item ON dm_item_history ( uuid, cm_revision );

CREATE TABLE ha_assessment ( 
	uuid                 char(38) NOT NULL  PRIMARY KEY  ,
	[type]               char(100) NOT NULL DEFAULT 'pending'   ,
	description          text     ,
	severity             integer NOT NULL DEFAULT 0   ,
	avoidance            integer NOT NULL DEFAULT 0   ,
	frequency            integer NOT NULL DEFAULT 0   ,
	probability          integer NOT NULL DEFAULT 0   ,
	cm_deleted           boolean NOT NULL DEFAULT 0   ,
	cm_modified_by       char(38) NOT NULL    ,
	cm_revision          integer NOT NULL DEFAULT 0   ,
	cm_timestamp         datetime NOT NULL DEFAULT CURRENT_TIMESTAMP   ,
	repository           char(38) NOT NULL    
 );

CREATE TABLE ha_assessment_history ( 
	uuid                 char(38) NOT NULL    ,
	[type]               char(100) NOT NULL DEFAULT 'pending'   ,
	description          text     ,
	severity             integer NOT NULL DEFAULT 0   ,
	avoidance            integer NOT NULL DEFAULT 0   ,
	frequency            integer NOT NULL DEFAULT 0   ,
	probability          integer NOT NULL DEFAULT 0   ,
	cm_deleted           boolean NOT NULL DEFAULT 0   ,
	cm_modified_by       char(38) NOT NULL    ,
	cm_revision          integer NOT NULL DEFAULT 0   ,
	cm_timestamp         datetime NOT NULL DEFAULT CURRENT_TIMESTAMP   ,
	repository           char(38) NOT NULL    
 );

CREATE INDEX idx_ha_assessment_history ON ha_assessment_history ( uuid, cm_revision );

CREATE TABLE ha_hazard ( 
	uuid                 char(38) NOT NULL  PRIMARY KEY  ,
	solution             char(38) NOT NULL    ,
	ddo                  char(38) NOT NULL    ,
	lifecyclephases      text     ,
	typeofhazard         char(100)  DEFAULT 'pending'   ,
	description          text     ,
	alarp                boolean  DEFAULT 0   ,
	cm_deleted           boolean NOT NULL DEFAULT 0   ,
	cm_modified_by       char(38) NOT NULL    ,
	cm_revision          integer NOT NULL DEFAULT 0   ,
	cm_timestamp         datetime NOT NULL DEFAULT CURRENT_TIMESTAMP   ,
	repository           char(38) NOT NULL    
 );

CREATE TABLE ha_hazard_assessment ( 
	hazard               char(38) NOT NULL    ,
	assessment           char(38) NOT NULL    ,
	CONSTRAINT pk_ha_hazard_assessment PRIMARY KEY ( hazard, assessment ),
	CONSTRAINT Unq_ha_hazard_assessment_hazard UNIQUE ( hazard ) ,
	FOREIGN KEY ( assessment ) REFERENCES ha_assessment( uuid ) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY ( hazard ) REFERENCES ha_hazard( uuid ) ON DELETE CASCADE ON UPDATE CASCADE
 );

CREATE TABLE ha_hazard_history ( 
	uuid                 char(38) NOT NULL    ,
	solution             char(38) NOT NULL    ,
	ddo                  char(38) NOT NULL    ,
	lifecyclephases      text     ,
	typeofhazard         char(100)  DEFAULT 'pending'   ,
	description          text     ,
	alarp                boolean  DEFAULT 0   ,
	cm_deleted           boolean NOT NULL DEFAULT 0   ,
	cm_modified_by       char(38) NOT NULL    ,
	cm_revision          integer NOT NULL DEFAULT 0   ,
	cm_timestamp         datetime NOT NULL DEFAULT CURRENT_TIMESTAMP   ,
	repository           char(38) NOT NULL    ,
	CONSTRAINT idx_ha_hazard_history UNIQUE ( uuid, cm_revision ) 
 );

CREATE TABLE ha_mitigation ( 
	uuid                 char(38) NOT NULL  PRIMARY KEY  ,
	hazard               char(38)     ,
	description          text     ,
	[type]               char(100)  DEFAULT 'pending'   ,
	cm_deleted           boolean NOT NULL DEFAULT 0   ,
	cm_modified_by       char(38) NOT NULL    ,
	cm_revision          integer NOT NULL DEFAULT 0   ,
	cm_timestamp         datetime NOT NULL DEFAULT CURRENT_TIMESTAMP   ,
	repository           char(38) NOT NULL    ,
	FOREIGN KEY ( hazard ) REFERENCES ha_hazard( uuid ) ON DELETE CASCADE ON UPDATE CASCADE
 );

CREATE INDEX idx_ha_mitigation_hazard ON ha_mitigation ( hazard );

CREATE TABLE ha_mitigation_assessment ( 
	mitigation           char(38) NOT NULL    ,
	assessment           char(38) NOT NULL    ,
	CONSTRAINT pk_ha_mitigation_assessment PRIMARY KEY ( mitigation, assessment ),
	CONSTRAINT Unq_ha_mitigation_assessment_mitigation UNIQUE ( mitigation ) ,
	FOREIGN KEY ( assessment ) REFERENCES ha_assessment( uuid ) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY ( mitigation ) REFERENCES ha_mitigation( uuid ) ON DELETE CASCADE ON UPDATE CASCADE
 );

CREATE TABLE ha_mitigation_history ( 
	uuid                 char(38) NOT NULL    ,
	hazard               char(38)     ,
	description          text     ,
	[type]               char(100)  DEFAULT 'pending'   ,
	cm_deleted           boolean NOT NULL DEFAULT 0   ,
	cm_modified_by       char(38) NOT NULL    ,
	cm_revision          integer NOT NULL DEFAULT 0   ,
	cm_timestamp         datetime NOT NULL DEFAULT CURRENT_TIMESTAMP   ,
	repository           char(38) NOT NULL    ,
	CONSTRAINT idx_ha_mitigation_history UNIQUE ( uuid, cm_revision ) 
 );

CREATE TABLE re_document_history ( 
	uuid                 char(38) NOT NULL    ,
	solution             char(38)     ,
	documentNumber       varchar(255)     ,
	title                varchar(255)     ,
	revisionNumber       varchar(255)     ,
	publicationDate      date     ,
	category             varchar(100)  DEFAULT 'report'   ,
	dmsUrl               text     ,
	ismsClassification   varchar(100)     ,
	govClassification    varchar(100)     ,
	lang                 char(5)     ,
	layout               char(38)     ,
	template             char(38)     ,
	properties           text     ,
	cm_owner             char(38)     ,
	cm_revision          integer  DEFAULT 0   ,
	cm_deleted           boolean  DEFAULT false   ,
	cm_timestamp         datetime  DEFAULT CURRENT_TIMESTAMP   ,
	cm_modifiedBy        char(38)     
 );

CREATE INDEX pk_re_document_history ON re_document_history ( uuid, cm_revision );

CREATE TABLE re_section_ddl ( 
	section_uuid         char(38) NOT NULL    ,
	section_revision     integer NOT NULL    ,
	ddl_uuid             char(38) NOT NULL    ,
	ddl_revision         integer     
 );

CREATE INDEX Idx_re_section_ddo_0 ON re_section_ddl ( section_uuid, section_revision, ddl_uuid, ddl_revision );

CREATE TABLE re_section_ddo ( 
	section_uuid         char(38) NOT NULL    ,
	section_revision     integer NOT NULL    ,
	ddo_uuid             char(38) NOT NULL    ,
	ddo_revision         integer     
 );

CREATE INDEX Idx_re_section_ddo ON re_section_ddo ( section_uuid, section_revision, ddo_uuid, ddo_revision );

CREATE TABLE re_section_history ( 
	uuid                 char(38) NOT NULL  PRIMARY KEY  ,
	document             char(38)     ,
	number               varchar(255)     ,
	caption              varchar(255)     ,
	description          text     ,
	script               char(38)     ,
	options              blob     ,
	cm_modified_by       char(38)     ,
	cm_owner             char(38)     ,
	cm_revision          integer  DEFAULT 0   ,
	cm_deleted           boolean  DEFAULT false   ,
	cm_timestamp         datetime  DEFAULT CURRENT_TIMESTAMP   
 );

CREATE INDEX idx_re_section_document_0 ON re_section_history ( document );

CREATE INDEX idx_re_section_script_0 ON re_section_history ( script );

CREATE TABLE re_template ( 
	uuid                 char(38)     ,
	id                   varchar(255)     ,
	definition           blob     ,
	timestamp            datetime  DEFAULT CURRENT_TIMESTAMP   ,
	repository           char(38)     ,
	CONSTRAINT Unq_rf_template_uuid UNIQUE ( uuid ) 
 );

CREATE TABLE rp_config ( 
	key                  varchar(255) NOT NULL  PRIMARY KEY  ,
	value                blob     
 );

CREATE TABLE rp_member ( 
	uuid                 char(38) NOT NULL  PRIMARY KEY  ,
	account              varchar(100) NOT NULL    ,
	name                 varchar(100) NOT NULL    ,
	radmin               bit  DEFAULT 0   ,
	repository           char(38) NOT NULL    ,
	password             blob NOT NULL    ,
	email                char(255)     ,
	phone                char(255)     ,
	locked               boolean  DEFAULT 0   
 );

CREATE TABLE rp_project ( 
	uuid                 char(38) NOT NULL  PRIMARY KEY  ,
	name                 varchar(100) NOT NULL    ,
	state                varchar(100)  DEFAULT 'locked'   ,
	description          text     ,
	properties           text     ,
	repository           char(38) NOT NULL    
 );

CREATE TABLE rp_project_config ( 
	project              char(38)     ,
	key                  varchar(255)     ,
	value                blob     ,
	CONSTRAINT pk_rp_project_config UNIQUE ( project, key ) ,
	FOREIGN KEY ( project ) REFERENCES rp_project( uuid ) ON DELETE CASCADE 
 );

CREATE INDEX Idx_rp_project_config_project ON rp_project_config ( project );

CREATE TABLE rp_project_member ( 
	project              char(38) NOT NULL    ,
	member               char(38) NOT NULL    ,
	mode                 varchar(100)  DEFAULT readwrite   ,
	CONSTRAINT pk_po_project_member PRIMARY KEY ( project, member ),
	FOREIGN KEY ( member ) REFERENCES rp_member( uuid ) ON DELETE CASCADE ,
	FOREIGN KEY ( project ) REFERENCES rp_project( uuid ) ON DELETE CASCADE 
 );

CREATE TABLE rp_solution_space ( 
	uuid                 char(38) NOT NULL  PRIMARY KEY  ,
	name                 varchar(100)     ,
	project              char(38)     ,
	description          text     ,
	enabled              boolean NOT NULL DEFAULT false   ,
	readonly             boolean NOT NULL DEFAULT false   ,
	repository           char(38) NOT NULL    ,
	CONSTRAINT uix_dd_variant_name UNIQUE ( name, project ) ,
	FOREIGN KEY ( project ) REFERENCES rp_project( uuid ) ON DELETE CASCADE ON UPDATE CASCADE
 );

CREATE INDEX idx_dd_variant_project ON rp_solution_space ( project );

CREATE TABLE rp_transaction ( 
	uuid                 char(38) NOT NULL  PRIMARY KEY  ,
	name                 varchar(100)     ,
	description          text     
 );

CREATE INDEX idx_rp_transaction_name ON rp_transaction ( name );

CREATE TABLE sp_issue ( 
	uuid                 char(38) NOT NULL  PRIMARY KEY  ,
	title                varchar(255)     ,
	description          text     ,
	degree_of_completion integer  DEFAULT 0   ,
	start_date           date     ,
	due_date             date     ,
	date_of_completion   date     ,
	state                varchar(100)     ,
	priority             varchar(100)     ,
	responsible          char(38)     ,
	tracker              varchar(100)  DEFAULT 'reposyd'   ,
	solution             char(38)     ,
	repository           char(38) NOT NULL    ,
	workflow             varchar(100)  DEFAULT 'none'   ,
	dd_uuid              char(38)     ,
	dd_type              varchar(100)     ,
	cm_revision          bigint  DEFAULT 0   ,
	cm_timestamp         datetime  DEFAULT CURRENT_TIMESTAMP   ,
	cm_owner             char(38)     ,
	cm_modified_by       char(38)     ,
	cm_deleted           boolean  DEFAULT 0   ,
	FOREIGN KEY ( solution ) REFERENCES rp_solution_space( uuid ) ON DELETE CASCADE 
 );

CREATE INDEX Idx_sp_issue_solution ON sp_issue ( solution );

CREATE TABLE sp_issue_history ( 
	uuid                 char(38) NOT NULL  PRIMARY KEY  ,
	title                varchar(255)     ,
	description          text     ,
	degree_of_completion integer  DEFAULT 0   ,
	start_date           date     ,
	due_date             date     ,
	date_of_completion   date     ,
	state                varchar(100)     ,
	priority             varchar(100)     ,
	responsible          char(38)     ,
	tracker              varchar(100)  DEFAULT 'reposyd'   ,
	solution             char(38)     ,
	repository           char(38)     ,
	workflow             varchar(100)  DEFAULT 'none'   ,
	dd_uuid              char(38)     ,
	dd_type              varchar(100)     ,
	cm_revision          bigint  DEFAULT 0   ,
	cm_timestamp         datetime  DEFAULT CURRENT_TIMESTAMP   ,
	cm_owner             char(38)     ,
	cm_modified_by       char(38)     ,
	cm_deleted           boolean     
 );

CREATE INDEX Idx_sp_issue_solution_0 ON sp_issue_history ( solution );

CREATE TABLE sp_messagebox ( 
	uuid                 char(38) NOT NULL  PRIMARY KEY  ,
	member               char(38) NOT NULL    ,
	message              text     ,
	read                 datetime     ,
	timestamp            datetime  DEFAULT CURRENT_TIMESTAMP   ,
	project              char(38) NOT NULL    ,
	FOREIGN KEY ( project ) REFERENCES rp_project( uuid ) ON DELETE CASCADE ,
	FOREIGN KEY ( member ) REFERENCES rp_member( uuid ) ON DELETE CASCADE 
 );

CREATE INDEX idx_rp_messagebox_project ON sp_messagebox ( project );

CREATE INDEX idx_rp_messagebox_member ON sp_messagebox ( member );

CREATE TABLE sp_script ( 
	uuid                 char(38)     ,
	[type]               varchar(100)     ,
	domain               char(38)  DEFAULT '<global>'   ,
	name                 varchar(100)     ,
	code                 blob     ,
	cm_revision          integer  DEFAULT 0   ,
	cm_timestamp         datetime  DEFAULT CURRENT_TIMESTAMP   ,
	cm_modified_by       char(38) NOT NULL    ,
	cm_deleted           boolean  DEFAULT 0   ,
	CONSTRAINT uix_se_script_uuid UNIQUE ( uuid ) ,
	CONSTRAINT unq_sp_script UNIQUE ( [type], name ) 
 );

CREATE TABLE sp_sys_log ( 
	timestamp            datetime  DEFAULT CURRENT_TIMESTAMP   ,
	level                varchar(100) NOT NULL    ,
	category             varchar(100)     ,
	message              text     ,
	originator           varchar(38)  DEFAULT '<system>'   
 );

CREATE TABLE sp_tags ( 
	name                 char(255) NOT NULL  PRIMARY KEY  ,
	uuid                 char(38)     ,
	CONSTRAINT Idx_sp_tags_uuid UNIQUE ( uuid ) 
 );

CREATE TABLE sp_tags_ddo ( 
	ddo                  char(38) NOT NULL    ,
	tag                  char(38) NOT NULL    ,
	CONSTRAINT Pk_sp_tags_ddo PRIMARY KEY ( ddo, tag ),
	FOREIGN KEY ( tag ) REFERENCES sp_tags( uuid )  
 );

CREATE TABLE sp_translation ( 
	uuid                 char(38) NOT NULL    ,
	code                 char(5) NOT NULL    ,
	key                  varchar(100) NOT NULL    ,
	translation          text     ,
	dirty                boolean  DEFAULT 0   ,
	revisionFrom         integer  DEFAULT -1   ,
	revisionTo           integer  DEFAULT -1   ,
	acceptedBy           char(38)     ,
	acceptedTimestamp    datetime     ,
	timestamp            datetime NOT NULL DEFAULT CURRENT_TIMESTAMP   ,
	CONSTRAINT pk_sp_translation PRIMARY KEY ( uuid, code, key )
 );

CREATE TABLE sp_user_log ( 
	timestamp            datetime  DEFAULT CURRENT_TIMESTAMP   ,
	category             varchar(100)     ,
	message              text     ,
	user                 char(38)     
 );

CREATE TABLE sp_watcher ( 
	member               char(38)     ,
	solution             char(38)     ,
	[type]               char(100)  DEFAULT 'ddo'   ,
	uuid                 integer     
 );

CREATE TABLE cm_baseline ( 
	uuid                 char(38) NOT NULL  PRIMARY KEY  ,
	dsuuid               char(38) NOT NULL    ,
	name                 varchar(255) NOT NULL    ,
	description          text     ,
	major                integer NOT NULL    ,
	minor                integer NOT NULL    ,
	[type]               varchar(100)     ,
	cm_timestamp         datetime  DEFAULT CURRENT_TIMESTAMP   ,
	cm_modified_by       char(38) NOT NULL    ,
	repository           char(38) NOT NULL    ,
	CONSTRAINT unq_cm_baseline_major_minor UNIQUE ( uuid, major, minor ) ,
	FOREIGN KEY ( dsuuid ) REFERENCES rp_solution_space( uuid ) ON DELETE CASCADE 
 );

CREATE TABLE cm_ddl ( 
	bl_uuid              char(38) NOT NULL    ,
	dl_uuid              char(38) NOT NULL    ,
	dl_revision          integer NOT NULL    ,
	FOREIGN KEY ( bl_uuid ) REFERENCES cm_baseline( uuid ) ON DELETE CASCADE 
 );

CREATE INDEX Idx_cm_ddl ON cm_ddl ( bl_uuid, dl_uuid );

CREATE TABLE cm_ddo ( 
	bl_uuid              char(38) NOT NULL    ,
	do_uuid              char(38) NOT NULL    ,
	do_revision          integer NOT NULL    ,
	FOREIGN KEY ( bl_uuid ) REFERENCES cm_baseline( uuid ) ON DELETE CASCADE 
 );

CREATE INDEX Idx_cm_ddo ON cm_ddo ( bl_uuid, do_uuid );

CREATE TABLE cm_diagram ( 
	bl_uuid              char(38) NOT NULL    ,
	dm_uuid              char(38) NOT NULL    ,
	cm_revision          integer NOT NULL    ,
	di_uuid              char(38) NOT NULL    ,
	di_revision          integer NOT NULL    ,
	FOREIGN KEY ( bl_uuid ) REFERENCES cm_baseline( uuid ) ON DELETE CASCADE 
 );

CREATE INDEX Idx_cm_diagram ON cm_diagram ( bl_uuid, dm_uuid, cm_revision, di_uuid, di_revision );

CREATE TABLE cm_document ( 
	bl_uuid              char(38) NOT NULL    ,
	dt_uuid              char(38) NOT NULL    ,
	dt_revision          integer NOT NULL    ,
	sn_uuid              char(38) NOT NULL    ,
	sn_revision          integer NOT NULL    ,
	FOREIGN KEY ( bl_uuid ) REFERENCES cm_baseline( uuid ) ON DELETE CASCADE 
 );

CREATE INDEX Idx_cm_document ON cm_document ( bl_uuid, dt_uuid );

CREATE TABLE cm_hazard_assessment ( 
	bl_uuid              char(38) NOT NULL    ,
	hz_uuid              char(38) NOT NULL    ,
	hz_revision          integer NOT NULL    ,
	as_uuid              char(38) NOT NULL    ,
	as_revision          integer NOT NULL    ,
	CONSTRAINT idx_cm_hazard UNIQUE ( bl_uuid, hz_uuid, hz_revision, as_uuid, as_revision ) ,
	FOREIGN KEY ( bl_uuid ) REFERENCES cm_baseline( uuid ) ON DELETE CASCADE 
 );

CREATE TABLE cm_mitigation_assessment ( 
	bl_uuid              char(38) NOT NULL    ,
	mn_uuid              char(38) NOT NULL    ,
	mn_revision          integer NOT NULL    ,
	as_uuid              char(38) NOT NULL    ,
	as_revision          integer NOT NULL    ,
	hz_uuid              char(38) NOT NULL    ,
	hz_revision          integer NOT NULL    ,
	FOREIGN KEY ( bl_uuid ) REFERENCES cm_baseline( uuid ) ON DELETE CASCADE 
 );

CREATE INDEX Idx_cm_mitigation_assessment ON cm_mitigation_assessment ( bl_uuid, mn_uuid, mn_revision );

CREATE TABLE cm_request ( 
	uuid                 char(38) NOT NULL  PRIMARY KEY  ,
	dsuuid               char(38) NOT NULL    ,
	description          text     ,
	state                varchar(100) NOT NULL DEFAULT 'invalid'   ,
	repository           char(38)     ,
	FOREIGN KEY ( dsuuid ) REFERENCES rp_solution_space( uuid ) ON DELETE CASCADE ON UPDATE CASCADE
 );

CREATE TABLE cm_section_ddo ( 
	bl_uuid              char(38) NOT NULL    ,
	sn_uuid              char(38) NOT NULL    ,
	sn_revision          integer NOT NULL    ,
	ddo_uuid             char(38) NOT NULL    ,
	ddo_revision         integer NOT NULL    ,
	FOREIGN KEY ( bl_uuid ) REFERENCES cm_baseline( uuid ) ON DELETE CASCADE 
 );

CREATE TABLE da_analysis_container ( 
	uuid                 char(38) NOT NULL  PRIMARY KEY  ,
	solution             char(38) NOT NULL    ,
	name                 varchar(255)     ,
	definition           char(38) NOT NULL    ,
	state                varchar(100)  DEFAULT 'closed'   ,
	description          text     ,
	repository           char  NOT NULL    ,
	FOREIGN KEY ( definition ) REFERENCES da_analysis_definition( uuid ) ON DELETE CASCADE ON UPDATE CASCADE
 );

CREATE INDEX idx_da_analysis_definition ON da_analysis_container ( definition );

CREATE TABLE da_analysis_result ( 
	uuid                 char(38) NOT NULL    ,
	container            char(38) NOT NULL    ,
	revision             integer NOT NULL DEFAULT 0   ,
	state                varchar(100)  DEFAULT 'pending'   ,
	timestamp            datetime NOT NULL DEFAULT CURRENT_TIMESTAMP   ,
	modifiedby           char(38) NOT NULL    ,
	CONSTRAINT sqlite_autoindex_da_analysis_result_1 UNIQUE ( container ) ,
	CONSTRAINT Unq_da_analysis_result_uuid UNIQUE ( uuid ) ,
	FOREIGN KEY ( container ) REFERENCES da_analysis_container( uuid ) ON DELETE CASCADE ON UPDATE CASCADE
 );

CREATE INDEX Idx_da_result_analysis ON da_analysis_result ( container );

CREATE TABLE da_analysis_result_properties ( 
	uuid                 char(38) NOT NULL  PRIMARY KEY  ,
	result               char(38) NOT NULL    ,
	key                  varchar(100)     ,
	value                blob     ,
	repository           char(38) NOT NULL    ,
	FOREIGN KEY ( result ) REFERENCES da_analysis_result( uuid ) ON DELETE CASCADE ON UPDATE CASCADE
 );

CREATE INDEX idx_da_analysis_result_properties_result ON da_analysis_result_properties ( result );

CREATE TABLE dd_def_object ( 
	uuid                 char(38) NOT NULL  PRIMARY KEY  ,
	project              char(38) NOT NULL    ,
	id                   char(2) NOT NULL    ,
	description          text     ,
	repository           char(38) NOT NULL    ,
	icon                 blob     ,
	shareable            boolean  DEFAULT 1   ,
	properties           blob     ,
	rules                blob     ,
	CONSTRAINT idx_dd_def_object_uuid UNIQUE ( uuid ) ,
	FOREIGN KEY ( project ) REFERENCES rp_project( uuid ) ON DELETE CASCADE 
 );

CREATE INDEX idx_ddo_definition ON dd_def_object ( project );

CREATE TABLE dd_object ( 
	uuid                 char(38) NOT NULL  PRIMARY KEY  ,
	definition           char(38) NOT NULL    ,
	localId              integer NOT NULL DEFAULT 0   ,
	masterId             integer  DEFAULT 0   ,
	cm_revision          integer NOT NULL DEFAULT 0   ,
	cm_modified_by       char(38) NOT NULL    ,
	created              datetime NOT NULL DEFAULT CURRENT_TIMESTAMP   ,
	cm_timestamp         datetime NOT NULL DEFAULT CURRENT_TIMESTAMP   ,
	repository           char(38) NOT NULL    ,
	FOREIGN KEY ( definition ) REFERENCES dd_def_object( uuid )  ,
	FOREIGN KEY ( cm_modified_by ) REFERENCES rp_member( uuid ) ON DELETE SET NULL 
 );

CREATE INDEX idx_dd_object_definition ON dd_object ( definition );

CREATE INDEX idx_dd_object_modifiedBy ON dd_object ( cm_modified_by );

CREATE TABLE dd_objectid ( 
	ddo                  char(38) NOT NULL  PRIMARY KEY  ,
	nextId               integer  DEFAULT 1   ,
	FOREIGN KEY ( ddo ) REFERENCES dd_def_object( uuid ) ON DELETE CASCADE 
 );

CREATE TABLE dd_template ( 
	uuid                 char(38) NOT NULL  PRIMARY KEY  ,
	id                   varchar(100)     ,
	ddo                  char(38)     ,
	template             blob     ,
	category             varchar(100)     ,
	cm_modified_by       char(38)     ,
	cm_timestamp         datetime  DEFAULT CURRENT_TIMESTAMP   ,
	repository           char(38)     ,
	FOREIGN KEY ( ddo ) REFERENCES dd_def_object( uuid ) ON DELETE CASCADE ON UPDATE CASCADE
 );

CREATE INDEX idx_dd_template_ddo ON dd_template ( ddo );

CREATE TABLE po_ipt ( 
	uuid                 char(38) NOT NULL  PRIMARY KEY  ,
	name                 varchar(100) NOT NULL    ,
	project              char(38) NOT NULL    ,
	description          text     ,
	[type]               varchar(100)     ,
	repository           char(38) NOT NULL    ,
	FOREIGN KEY ( project ) REFERENCES rp_project( uuid )  
 );

CREATE INDEX idx_po_ipt ON po_ipt ( project );

CREATE TABLE po_ipt_member ( 
	member               char(38) NOT NULL    ,
	ipt                  char(38) NOT NULL    ,
	project              char(38) NOT NULL    ,
	CONSTRAINT pk_po_ipt_member PRIMARY KEY ( member, ipt ),
	FOREIGN KEY ( ipt ) REFERENCES po_ipt( uuid )  ,
	FOREIGN KEY ( member, project ) REFERENCES rp_project_member( member, project ) ON DELETE CASCADE 
 );

CREATE INDEX idx_po_ipt_member_member ON po_ipt_member ( member );

CREATE INDEX idx_po_ipt_member_ipt ON po_ipt_member ( ipt );

CREATE TABLE po_role ( 
	uuid                 char(38) NOT NULL  PRIMARY KEY  ,
	project              char(38) NOT NULL    ,
	id                   varchar(100) NOT NULL    ,
	description          text     ,
	state                varchar(100)  DEFAULT 'enabled'   ,
	repository           char(38) NOT NULL    ,
	CONSTRAINT Unq_po_role_uuid UNIQUE ( uuid, project ) ,
	CONSTRAINT Unq_po_role_project UNIQUE ( project, uuid ) ,
	FOREIGN KEY ( project ) REFERENCES rp_project( uuid ) ON DELETE CASCADE 
 );

CREATE INDEX idx_po_role ON po_role ( project );

CREATE TABLE po_role_ddo_transaction ( 
	role                 char(38) NOT NULL    ,
	ddo                  char(38) NOT NULL    ,
	transaction_uuid     char(38) NOT NULL    ,
	CONSTRAINT pk_po_ddo_transaction PRIMARY KEY ( ddo, transaction_uuid, role ),
	FOREIGN KEY ( transaction_uuid ) REFERENCES rp_transaction( uuid )  ,
	FOREIGN KEY ( ddo ) REFERENCES dd_def_object( uuid )  ,
	FOREIGN KEY ( role ) REFERENCES po_role( uuid ) ON DELETE CASCADE 
 );

CREATE INDEX idx_po_ddo_transaction_ddo ON po_role_ddo_transaction ( ddo );

CREATE INDEX idx_po_ddo_transaction_id ON po_role_ddo_transaction ( transaction_uuid );

CREATE INDEX idx_po_ddo_transaction_role ON po_role_ddo_transaction ( role );

CREATE TABLE po_role_member ( 
	project              char(38) NOT NULL    ,
	role                 char(38) NOT NULL    ,
	member               char(38) NOT NULL    ,
	CONSTRAINT pk_po_role_member PRIMARY KEY ( role, member, project ),
	FOREIGN KEY ( project, role ) REFERENCES po_role( project, uuid ) ON DELETE CASCADE 
 );

CREATE INDEX idx_po_role_member ON po_role_member ( role );

CREATE INDEX idx_po_role_member_0 ON po_role_member ( member );

CREATE TABLE po_role_transaction ( 
	role                 char(38) NOT NULL    ,
	transaction_uuid     char(38) NOT NULL    ,
	CONSTRAINT pk_po_role_transaction PRIMARY KEY ( role, transaction_uuid ),
	FOREIGN KEY ( role ) REFERENCES po_role( uuid )  ,
	FOREIGN KEY ( transaction_uuid ) REFERENCES rp_transaction( uuid )  
 );

CREATE INDEX idx_po_role_transaction ON po_role_transaction ( transaction_uuid );

CREATE INDEX idx_po_role_transaction_0 ON po_role_transaction ( role );

CREATE TABLE re_layout ( 
	uuid                 char(38) NOT NULL  PRIMARY KEY  ,
	solution             char(38)     ,
	name                 varchar(255)     ,
	description          text     ,
	cm_modified_by       char(38) NOT NULL    ,
	cm_revision          integer  DEFAULT 0   ,
	cm_timestamp         datetime  DEFAULT CURRENT_TIMESTAMP   ,
	cm_deleted           integer  DEFAULT 0   ,
	repository           char(38)     ,
	FOREIGN KEY ( solution ) REFERENCES rp_solution_space( uuid ) ON DELETE CASCADE 
 );

CREATE TABLE re_reportformat ( 
	layout               char(38)     ,
	format               varchar(100)     ,
	enabled              boolean  DEFAULT 0   ,
	data                 blob     ,
	url                  varchar(255)     ,
	FOREIGN KEY ( layout ) REFERENCES re_layout( uuid ) ON DELETE CASCADE 
 );

CREATE INDEX idx_re_stylesheet_format ON re_reportformat ( format );

CREATE INDEX idx_re_stylesheet_layout ON re_reportformat ( layout );

CREATE TABLE re_template_solution ( 
	template             char(38) NOT NULL    ,
	solution             char(38)     ,
	CONSTRAINT unq_template_solution UNIQUE ( template, solution ) ,
	CONSTRAINT idx_rf_template_solution_template UNIQUE ( template ) ,
	FOREIGN KEY ( template ) REFERENCES re_template( uuid ) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY ( solution ) REFERENCES rp_solution_space( uuid ) ON DELETE CASCADE ON UPDATE CASCADE
 );

CREATE INDEX idx_rf_template_solution_solution ON re_template_solution ( solution );

CREATE TABLE rp_lock ( 
	project              char(38) NOT NULL    ,
	member               char(38) NOT NULL    ,
	uuid                 char(38) NOT NULL    ,
	timestamp            datetime  DEFAULT CURRENT_TIMESTAMP   ,
	master               char(38)     ,
	FOREIGN KEY ( project ) REFERENCES rp_project( uuid ) ON DELETE CASCADE ,
	FOREIGN KEY ( member ) REFERENCES rp_member( uuid ) ON DELETE CASCADE 
 );

CREATE INDEX idx_rp_lock_uuid ON rp_lock ( uuid );

CREATE INDEX idx_rp_lock_member ON rp_lock ( member );

CREATE INDEX Idx_rp_lock_project ON rp_lock ( project );

CREATE TABLE rp_member_settings ( 
	project              char(38) NOT NULL    ,
	member               char(38) NOT NULL    ,
	key                  varchar(255) NOT NULL    ,
	value                blob     ,
	CONSTRAINT pk_po_member_settings PRIMARY KEY ( project, member, key ),
	FOREIGN KEY ( member ) REFERENCES rp_member( uuid ) ON DELETE CASCADE ,
	FOREIGN KEY ( project ) REFERENCES rp_project( uuid ) ON DELETE CASCADE 
 );

CREATE INDEX Idx_po_member_settings_member ON rp_member_settings ( member );

CREATE INDEX Idx_po_member_settings_project ON rp_member_settings ( project );

CREATE TABLE sp_comment ( 
	uuid                 char(38) NOT NULL  PRIMARY KEY  ,
	member               char(38) NOT NULL    ,
	comment              text     ,
	timestamp            datetime  DEFAULT CURRENT_TIMESTAMP   ,
	ddo                  char(38)     ,
	revision             integer  DEFAULT 0   ,
	parent               char(38)     ,
	repository           char(38) NOT NULL    ,
	FOREIGN KEY ( ddo ) REFERENCES dd_object( uuid ) ON DELETE CASCADE ,
	FOREIGN KEY ( member ) REFERENCES rp_member( uuid )  
 );

CREATE INDEX idx_sp_comments_ddo ON sp_comment ( ddo );

CREATE INDEX idx_sp_comments_member ON sp_comment ( member );

CREATE TABLE da_analysis_object ( 
	result               char(38)     ,
	ddo                  char(38)     ,
	revision_from        integer     ,
	revision_to          integer  DEFAULT -1   ,
	matrix               char(100)  DEFAULT 'row'   ,
	FOREIGN KEY ( result ) REFERENCES da_analysis_result( uuid ) ON DELETE CASCADE 
 );

CREATE INDEX idx_da_analysis_object_result ON da_analysis_object ( result );

CREATE TABLE dd_ddo_solution ( 
	solution             char(38) NOT NULL    ,
	ddo                  char(38) NOT NULL    ,
	revision_from        integer NOT NULL DEFAULT -1   ,
	revision_to          integer NOT NULL DEFAULT -1   ,
	cm_owner             char(38)     ,
	responsible          char(38)     ,
	cm_modified_by       char(38)     ,
	cm_timestamp         datetime  DEFAULT CURRENT_TIMESTAMP   ,
	CONSTRAINT idx_dd_ddo_solution_ddo UNIQUE ( ddo ) ,
	CONSTRAINT pk_dd_visibility_ddo PRIMARY KEY ( solution, ddo, revision_from, revision_to ),
	CONSTRAINT Unq_dd_ddo_solution_solution UNIQUE ( solution, ddo ) ,
	FOREIGN KEY ( solution ) REFERENCES rp_solution_space( uuid ) ON DELETE CASCADE ,
	FOREIGN KEY ( ddo ) REFERENCES dd_object( uuid )  ,
	FOREIGN KEY ( responsible ) REFERENCES po_ipt( uuid ) ON DELETE SET NULL ON UPDATE CASCADE,
	FOREIGN KEY ( cm_owner ) REFERENCES po_ipt( uuid ) ON DELETE SET NULL ON UPDATE CASCADE
 );

CREATE INDEX idx_dd_ddo_solution_soluition ON dd_ddo_solution ( solution );

CREATE INDEX idx_dd_ddo_solution_modifiedBy ON dd_ddo_solution ( cm_modified_by );

CREATE INDEX idx_dd_ddo_solution_responsible ON dd_ddo_solution ( responsible );

CREATE INDEX idx_dd_ddo_solution_owner ON dd_ddo_solution ( cm_owner );

CREATE TABLE dd_def_attribute ( 
	uuid                 char(38) NOT NULL  PRIMARY KEY  ,
	id                   varchar(255) NOT NULL    ,
	description          text     ,
	ddo                  char(38) NOT NULL    ,
	[type]               varchar(100)     ,
	defaultValue         blob     ,
	sortOrder            integer  DEFAULT 100   ,
	properties           text     ,
	precision            integer     ,
	decimals             integer     ,
	unit                 varchar(100)     ,
	enums                blob     ,
	repository           char(38) NOT NULL    ,
	CONSTRAINT idx_dd_def_attribute_unique UNIQUE ( id, ddo ) ,
	FOREIGN KEY ( ddo ) REFERENCES dd_def_object( uuid ) ON DELETE CASCADE 
 );

CREATE INDEX idx_dd_def_attribute_ddo ON dd_def_attribute ( ddo );

CREATE TABLE dd_def_enum ( 
	uuid                 char(38) NOT NULL  PRIMARY KEY  ,
	dda                  char(38) NOT NULL    ,
	ekey                 varchar(100)     ,
	evalue               varchar(100)     ,
	description          text     ,
	properties           blob     ,
	repository           char(38) NOT NULL    ,
	CONSTRAINT unq_dd_def_enum UNIQUE ( dda, ekey ) ,
	FOREIGN KEY ( dda ) REFERENCES dd_def_attribute( uuid ) ON DELETE CASCADE 
 );

CREATE TABLE dd_def_link ( 
	uuid                 char(38) NOT NULL  PRIMARY KEY  ,
	project              char(38) NOT NULL    ,
	id                   varchar(100) NOT NULL    ,
	description          text     ,
	left                 char(38) NOT NULL    ,
	cardinality          varchar(100)     ,
	right                char(38) NOT NULL    ,
	reverse              char(38)     ,
	direction            char(2)  DEFAULT LR   ,
	repository           char(38) NOT NULL    ,
	FOREIGN KEY ( project ) REFERENCES rp_project( uuid ) ON DELETE CASCADE ,
	FOREIGN KEY ( left ) REFERENCES dd_def_object( uuid ) ON DELETE CASCADE ,
	FOREIGN KEY ( right ) REFERENCES dd_def_object( uuid ) ON DELETE CASCADE 
 );

CREATE INDEX idx_dd_def_link ON dd_def_link ( project );

CREATE INDEX idx_dd_def_link_left ON dd_def_link ( left );

CREATE INDEX idx_dd_def_link_right ON dd_def_link ( right );

CREATE INDEX Idx_dd_def_link_backward ON dd_def_link ( reverse );

CREATE TABLE dd_def_link_reverse ( 
	backward             char(38) NOT NULL    ,
	foreward             char(38) NOT NULL    ,
	CONSTRAINT pk_dd_def_link_reverse PRIMARY KEY ( foreward, backward ),
	FOREIGN KEY ( foreward ) REFERENCES dd_def_link( uuid ) ON DELETE CASCADE ,
	FOREIGN KEY ( backward ) REFERENCES dd_def_link( uuid ) ON DELETE CASCADE 
 );

CREATE INDEX idx_dd_def_link_reverse_foreware ON dd_def_link_reverse ( foreward );

CREATE INDEX idx_dd_def_link_reverse_reverse ON dd_def_link_reverse ( backward );

CREATE TABLE dd_link ( 
	uuid                 char(38) NOT NULL  PRIMARY KEY  ,
	definition           char(38) NOT NULL    ,
	do_left              char(38) NOT NULL    ,
	do_right             char(38) NOT NULL    ,
	cm_modified_by       char(38) NOT NULL    ,
	cm_timestamp         datetime  DEFAULT CURRENT_TIMESTAMP   ,
	repository           char(38) NOT NULL    ,
	FOREIGN KEY ( definition ) REFERENCES dd_def_link( uuid ) ON DELETE CASCADE ,
	FOREIGN KEY ( do_left ) REFERENCES dd_object( uuid ) ON DELETE CASCADE ,
	FOREIGN KEY ( do_right ) REFERENCES dd_object( uuid ) ON DELETE CASCADE ,
	FOREIGN KEY ( cm_modified_by ) REFERENCES rp_member( uuid )  
 );

CREATE INDEX idx_dd_link_definition ON dd_link ( definition );

CREATE INDEX idx_dd_link_source ON dd_link ( do_left );

CREATE INDEX idx_dd_link_target ON dd_link ( do_right );

CREATE INDEX idx_dd_link_0 ON dd_link ( cm_modified_by );

CREATE TABLE po_role_ddl_transaction ( 
	role                 char(38) NOT NULL    ,
	ddl                  char(38) NOT NULL    ,
	transaction_uuid     char(38) NOT NULL    ,
	CONSTRAINT pk_po_role_ddl_transaction PRIMARY KEY ( role, ddl, transaction_uuid ),
	FOREIGN KEY ( role ) REFERENCES po_role( uuid ) ON DELETE CASCADE ,
	FOREIGN KEY ( ddl ) REFERENCES dd_def_link( uuid ) ON DELETE CASCADE ,
	FOREIGN KEY ( transaction_uuid ) REFERENCES rp_transaction( uuid )  
 );

CREATE INDEX idx_po_role_ddl_transaction ON po_role_ddl_transaction ( role );

CREATE INDEX idx_po_role_ddl_transaction_0 ON po_role_ddl_transaction ( ddl );

CREATE INDEX idx_po_role_ddl_transaction_1 ON po_role_ddl_transaction ( transaction_uuid );

CREATE TABLE re_document ( 
	uuid                 char(38) NOT NULL  PRIMARY KEY  ,
	solution             char(38)     ,
	documentNumber       varchar(255)     ,
	title                varchar(255)     ,
	revisionNumber       varchar(255)     ,
	publicationDate      date     ,
	category             varchar(100)  DEFAULT 'report'   ,
	dmsUrl               text     ,
	ismsClassification   varchar(100)     ,
	govClassification    varchar(100)     ,
	lang                 char(5)  DEFAULT 'en-US'   ,
	layout               char(38)     ,
	template             char(38)     ,
	properties           text     ,
	cm_owner             char(38)     ,
	cm_revision          integer  DEFAULT 0   ,
	cm_deleted           boolean  DEFAULT false   ,
	cm_timestamp         datetime  DEFAULT CURRENT_TIMESTAMP   ,
	cm_modified_by       char(38)     ,
	FOREIGN KEY ( layout ) REFERENCES re_layout( uuid ) ON DELETE SET NULL ON UPDATE SET NULL,
	FOREIGN KEY ( solution ) REFERENCES rp_solution_space( uuid ) ON DELETE CASCADE ,
	FOREIGN KEY ( template ) REFERENCES re_template_solution( template ) ON DELETE SET NULL ON UPDATE CASCADE
 );

CREATE INDEX Idx_re_report_stylesheet ON re_document ( layout );

CREATE INDEX Idx_re_document_solution ON re_document ( solution );

CREATE INDEX idx_re_document_template ON re_document ( template );

CREATE TABLE re_documenttree ( 
	parent               char(38) NOT NULL    ,
	child                char(38) NOT NULL    ,
	CONSTRAINT pk_re_documenttree PRIMARY KEY ( parent, child ),
	FOREIGN KEY ( parent ) REFERENCES re_document( uuid ) ON DELETE CASCADE ,
	FOREIGN KEY ( child ) REFERENCES re_document( uuid ) ON DELETE CASCADE 
 );

CREATE INDEX idx_re_documenttree_parent ON re_documenttree ( parent );

CREATE INDEX idx_re_documenttree_child ON re_documenttree ( child );

CREATE TABLE re_section ( 
	uuid                 char(38) NOT NULL  PRIMARY KEY  ,
	document             char(38)     ,
	number               varchar(255)     ,
	caption              varchar(255)     ,
	description          text     ,
	script               varchar(100)     ,
	options              blob     ,
	cm_modified_by       char(38)     ,
	cm_owner             char(38)     ,
	cm_revision          integer  DEFAULT 0   ,
	cm_deleted           boolean  DEFAULT false   ,
	cm_timestamp         datetime  DEFAULT CURRENT_TIMESTAMP   ,
	FOREIGN KEY ( document ) REFERENCES re_document( uuid ) ON DELETE CASCADE 
 );

CREATE INDEX idx_re_section_document ON re_section ( document );

CREATE INDEX idx_re_section_script ON re_section ( script );

CREATE TABLE re_section_dd ( 
	sn_uuid              char(38) NOT NULL    ,
	sn_revision          integer NOT NULL    ,
	dd_type              varchar(100) NOT NULL    ,
	dd_uuid              char(38) NOT NULL    ,
	dd_revision          integer NOT NULL    ,
	FOREIGN KEY ( sn_uuid ) REFERENCES re_section( uuid ) ON DELETE CASCADE 
 );

CREATE INDEX Idx_re_section_dd ON re_section_dd ( sn_uuid, sn_revision );

CREATE TABLE dd_attribute_value ( 
	dda                  char(38) NOT NULL    ,
	ddo                  char(38) NOT NULL    ,
	ddo_revision         integer     ,
	value                blob     ,
	timestamp            datetime  DEFAULT CURRENT_TIMESTAMP   ,
	CONSTRAINT pk_dd_attribute_value PRIMARY KEY ( ddo, dda ),
	FOREIGN KEY ( ddo ) REFERENCES dd_object( uuid )  ON UPDATE CASCADE,
	FOREIGN KEY ( dda ) REFERENCES dd_def_attribute( uuid )  ON UPDATE CASCADE
 );

CREATE INDEX idx_dda_value_ddo ON dd_attribute_value ( ddo );

CREATE INDEX idx_dda_value_dda ON dd_attribute_value ( dda );

CREATE TABLE dd_ddl_solution ( 
	solution             char(38) NOT NULL    ,
	ddl                  char(38) NOT NULL    ,
	left_from            integer NOT NULL DEFAULT -1   ,
	left_to              integer NOT NULL DEFAULT -1   ,
	right_from           integer NOT NULL DEFAULT -1   ,
	right_to             integer NOT NULL DEFAULT -1   ,
	accepted_by          char(38)     ,
	accepted_revision_left integer  DEFAULT -1   ,
	accepted_revision_right integer  DEFAULT -1   ,
	accepted_state       varchar(100)  DEFAULT unknown   ,
	accepted_comment     varchar(255)     ,
	cm_modified_by       char(38) NOT NULL    ,
	cm_revision          integer  DEFAULT 0   ,
	cm_timestamp         datetime  DEFAULT CURRENT_TIMESTAMP   ,
	CONSTRAINT pk_dd_variant_ddl PRIMARY KEY ( solution, ddl ),
	FOREIGN KEY ( solution ) REFERENCES rp_solution_space( uuid ) ON DELETE CASCADE ,
	FOREIGN KEY ( ddl ) REFERENCES dd_link( uuid )  
 );

CREATE INDEX idx_dd_variant_ddl_solution ON dd_ddl_solution ( solution );

CREATE INDEX idx_dd_variant_ddl_dd_link ON dd_ddl_solution ( ddl );

CREATE TABLE dd_def_hierarchy ( 
	uuid                 char(38) NOT NULL  PRIMARY KEY  ,
	project              char(38) NOT NULL    ,
	id                   char(255)     ,
	name                 varchar(255)     ,
	description          text     ,
	up                   char(38)     ,
	down                 char(38)     ,
	repository           char(38) NOT NULL    ,
	FOREIGN KEY ( project ) REFERENCES rp_project( uuid ) ON DELETE CASCADE ,
	FOREIGN KEY ( up ) REFERENCES dd_def_link( uuid ) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY ( down ) REFERENCES dd_def_link( uuid ) ON DELETE CASCADE ON UPDATE CASCADE
 );

CREATE INDEX idx_dd_def_hierarchy_up ON dd_def_hierarchy ( up );

CREATE INDEX idx_dd_def_hierarchy_down ON dd_def_hierarchy ( down );

CREATE INDEX idx_dd_def_hierarchy ON dd_def_hierarchy ( project );

CREATE TABLE ddh_ddo_dda_revision ( 
	dda                  char(38) NOT NULL    ,
	dda_revision         integer NOT NULL    ,
	ddo_revision         integer NOT NULL    ,
	CONSTRAINT _0 PRIMARY KEY ( dda, dda_revision, ddo_revision ),
	FOREIGN KEY ( dda ) REFERENCES dd_attribute_value( dda ) ON DELETE CASCADE 
 );

CREATE INDEX idx_ddh_ddo_dda_revision_dda ON ddh_ddo_dda_revision ( dda );

CREATE VIEW ac_ddl_assignments AS SELECT dd_def_link.project AS po_uuid,
       rp_transaction.name AS ta_name,
       po_role.id AS ro_id,
       po_role.state AS ro_state,
       dd_def_link.id AS dl_id,
       dd_def_link.uuid AS dl_uuid,
       dd_def_link.repository AS dl_repository,
       rp_member.uuid AS mb_uuid,
       rp_member.name AS mb_name,
       rp_member.account AS mb_account,
       rp_project_member.mode AS mb_mode,
       rp_member.repository AS mb_repository
  FROM po_role_ddl_transaction
       INNER JOIN
       dd_def_link ON (dd_def_link.uuid = po_role_ddl_transaction.ddl) 
       INNER JOIN
       rp_transaction ON (rp_transaction.uuid = po_role_ddl_transaction.transaction_uuid) 
       INNER JOIN
       po_role ON (po_role.uuid = po_role_ddl_transaction.role) 
       INNER JOIN
       po_role_member ON (po_role_member.role = po_role.uuid) 
       INNER JOIN
       rp_project_member ON (rp_project_member.member = po_role_member.member) 
       INNER JOIN
       rp_member ON (rp_member.uuid = rp_project_member.member);

CREATE VIEW ac_ddo_assignments AS SELECT dd_def_object.project AS po_uuid,
       rp_transaction.name AS ta_name,
       po_role.id AS ro_id,
       po_role.state AS ro_state,
       dd_def_object.id AS do_id,
       dd_def_object.uuid AS do_uuid,
       dd_def_object.repository AS do_repository,
       rp_member.uuid AS mb_uuid,
       rp_member.name AS mb_name,
       rp_member.account AS mb_account,
       rp_project_member.mode AS mb_mode,
       rp_member.repository AS mb_repository
  FROM po_role_ddo_transaction
       INNER JOIN
       dd_def_object ON (dd_def_object.uuid = po_role_ddo_transaction.ddo) 
       INNER JOIN
       rp_transaction ON (rp_transaction.uuid = po_role_ddo_transaction.transaction_uuid) 
       INNER JOIN
       po_role ON (po_role.uuid = po_role_ddo_transaction.role) 
       INNER JOIN
       po_role_member ON (po_role_member.role = po_role.uuid) 
       INNER JOIN
       rp_project_member ON (rp_project_member.member = po_role_member.member) 
       INNER JOIN
       rp_member ON (rp_member.uuid = rp_project_member.member);

CREATE VIEW ac_locked_ddl AS SELECT
*
FROM
ac_locks AS lck
INNER JOIN ds_ddl_na ddl ON (ddl.dl_uuid=lck.dd_uuid);

CREATE VIEW ac_locked_ddo AS SELECT
*
FROM
ac_locks AS lck
INNER JOIN ds_ddo_na ddo ON (ddo.do_uuid=lck.dd_uuid);

CREATE VIEW ac_locked_dt AS SELECT
*
FROM
ac_locks AS lck
INNER JOIN re_documents dt ON (dt.dt_uuid=lck.dd_uuid);

CREATE VIEW ac_locks AS SELECT lk.project AS po_uuid,
       lk.uuid AS dd_uuid,
       lk.timestamp AS lk_timestamp,
       lk.master AS lk_master,
       rpm.uuid AS mb_uuid,
       rpm.account AS mb_account,
       rpm.name AS mb_name       
  FROM rp_lock AS lk
       INNER JOIN
       rp_member rpm ON (rpm.uuid = lk.member);;

CREATE VIEW ac_owner AS SELECT ddo.solution AS ds_uuid,
       ddo.ddo AS do_uuid,
       ip.uuid AS ip_uuid,
       ip.name AS ip_name,
       ip.type AS ip_type,
       ip.description AS ip_description
  FROM dd_ddo_solution AS ddo
       LEFT JOIN
       po_ipt ip ON (ip.uuid = ddo.cm_owner) 
 WHERE ddo.revision_to == -1;

CREATE VIEW ac_roles AS SELECT ro.project AS po_uuid,
           ro.uuid AS ro_uuid,
           ro.id AS ro_id,
           ro.description AS ro_description,
           ro.state AS ro_state
      FROM po_role AS ro;;

CREATE VIEW ac_transactions AS SELECT uuid AS tn_uuid,name AS tn_name, description AS tn_description FROM rp_transaction;

CREATE VIEW cm_baselines AS SELECT bl.dsuuid AS ds_uuid,
       bl.uuid AS bl_uuid,
       bl.name AS bl_name,
       bl.description AS bl_description,
       bl.type AS bl_type,
       bl.major AS bl_major,
       bl.minor AS bl_minor,
       blmb.uuid AS bl_mb_uuid,
       blmb.account AS bl_mb_account,
       blmb.name AS bl_mb_name,
       bl.cm_timestamp AS bl_cm_timestamp,
       0 AS bl_cm_revision
  FROM cm_baseline AS bl
       INNER JOIN
       rp_member blmb ON (blmb.uuid = bl.cm_modified_by);

CREATE VIEW dac_container AS SELECT dac.solution AS ds_uuid,
           dac.uuid AS dac_uuid,
           dac.name AS dac_name,
           dac.state AS dac_state,
           dac.description AS dac_description,
           dac.definition AS dad_uuid,
           dad.type AS dad_type,
           dad.name AS dad_name,
           dad.description AS dad_description,
           dad.properties AS dad_properties
      FROM da_analysis_container AS dac
           INNER JOIN
           da_analysis_definition dad ON (dac.definition = dad.uuid);

CREATE VIEW dac_definition AS SELECT dad.uuid AS dad_uuid,
       dad.project AS po_uuid,
       dad.name AS dad_name,
       dad.description AS dad_description,
       dad.name AS do_name,
       dad.type AS dad_type,
       dad.properties AS dad_properties,
       dad.repository AS rp_uuid
  FROM da_analysis_definition AS dad;

CREATE VIEW dac_result AS SELECT dac.solution AS ds_uuid,
           dac.uuid AS dac_uuid,
           dar.uuid AS dar_uuid,
           dar.state AS dar_state,
           dar.revision AS dar_revision,
           dao.ddo AS dao_uuid,
           dao.matrix AS dao_matrix,
           rpm.uuid AS mb_uuid,
           rpm.account AS mb_account,
           rpm.name AS mb_name 
      FROM da_analysis_container AS dac
           INNER JOIN
           da_analysis_result dar ON (dar.container = dac.uuid) 
           INNER JOIN
           rp_member rpm ON (rpm.uuid = dar.modifiedby)
           INNER JOIN
           da_analysis_object dao ON (dao.result=dar.uuid);

CREATE VIEW dac_result_properties AS SELECT dac.solution AS ds_uuid,
       dac.uuid AS dac_uuid,
       dar.uuid AS dar_uuid,
       dar.state AS dar_state,
       dar.revision AS dar_revision,
       dao.ddo AS dao_uuid,
       dao.matrix AS dao_matrix,
       dap.key AS dap_key,
       dap.value AS dap_value,
       rpm.uuid AS mb_uuid,
       rpm.account AS mb_account,
       rpm.name AS mb_name
  FROM da_analysis_container AS dac
       INNER JOIN
       da_analysis_result dar ON (dar.container = dac.uuid) 
       INNER JOIN
       rp_member rpm ON (rpm.uuid = dar.modifiedby) 
       INNER JOIN
       da_analysis_object dao ON (dao.result = dar.uuid)
       LEFT JOIN
       da_analysis_result_properties dap ON (dap.result=dar.uuid);

CREATE VIEW dbs_validate_view AS SELECT dm.solution AS ds_uuid,
       di.uuid AS di_uuid,
       dm.uuid AS dm_uuid,
       di.type AS di_type,
       di.properties AS di_properties,
       di.ddoddl AS di_ddoddl,
       di.ghost AS di_ghost,
       di.revision_from AS di_revision_from
  FROM dm_item AS di
       LEFT JOIN
       dm_diagram dm ON (dm.uuid = di.diagram) 
 WHERE di.revision_to = -1;;

SELECT dm.solution AS ds_uuid,
           di.uuid AS di_uuid,
           dm.uuid AS dm_uuid,
           dm.type AS dm_type,
           di.type AS di_type,
           di.properties AS di_properties,
           di.ddoddl AS di_ddoddl,
           di.ghost AS di_ghost,
           di.revision_from AS di_revision_from,
           di.cm_revision AS di_cm_revision
      FROM dm_item AS di
           LEFT JOIN
           dm_diagram dm ON (dm.uuid = di.diagram) 
     WHERE di.revision_to = -1;;

CREATE VIEW dd_hierarchy AS SELECT dh.project AS po_uuid,
           dh.uuid AS dh_uuid,
           dh.name AS dh_name,
           dh.up AS dl_up_uuid,
           dh.down AS dl_down_uuid,
           dh.repository AS rp_uuid
      FROM dd_def_hierarchy AS dh;

CREATE VIEW ddo_locked AS SELECT rpl.project AS po_uuid,
       rpl.uuid AS do_uuid,
       rpl.timestamp AS lk_timestamp,
       rpm.uuid AS mb_uuid,
       rpm.account AS mb_account,
       rpm.name AS mb_name
  FROM rp_lock AS rpl
       INNER JOIN
       rp_member rpm ON (rpm.uuid = rpl.member);;

CREATE VIEW dm_diagrams AS SELECT dm.solution AS ds_uuid,
       dm.uuid AS dm_uuid,
       tr.code AS tr_code,
       tr.translation AS dm_name,
       dm.type AS dm_type,
       dm.properties AS dm_properties,
       dm.ddo AS do_uuid,
       dm.cm_revision AS cm_revision,
       dm.cm_modified_by AS cm_modified_by,
       dm.cm_timestamp AS cm_timestamp
  FROM dm_diagram AS dm
       LEFT JOIN
       sp_translation tr ON (tr.uuid = dm.uuid)
  WHERE dm.cm_deleted = 0;

SELECT dm.solution AS ds_uuid,
           di.uuid AS di_uuid,
           dm.uuid AS dm_uuid,
           dm.type AS dm_type,
           di.type AS di_type,
           di.properties AS di_properties,
           di.ddoddl AS di_ddoddl,
           di.ghost AS di_ghost,
           di.revision_from AS di_revision_from,
           di.cm_revision AS di_cm_revision
      FROM dm_item AS di
           LEFT JOIN
           dm_diagram dm ON (dm.uuid = di.diagram) 
     WHERE di.revision_to = -1;;

CREATE VIEW do_template AS SELECT dd.project AS po_uuid,
       dd.uuid AS do_uuid,
       dt.uuid AS dt_uuid,
       dt.id AS dt_id,
       dt.category AS dt_category,
       dt.template AS dt_template,
	   rpm.account AS dt_mb_account,
       rpm.uuid AS dt_mb_uuid,
       rpm.name AS dt_mb_name,
       dt.cm_timestamp AS dt_timestamp,
       dt.repository AS dt_repository
  FROM dd_def_object AS dd
       INNER JOIN
       dd_template dt ON (dt.ddo = dd.uuid)
	   LEFT JOIN
       rp_member rpm ON (rpm.uuid = dt.cm_modified_by);

CREATE VIEW ds_ddl_left AS SELECT ddl.ds_uuid,
       ddl.dl_uuid,
       ddl.dl_definition,
       ddl.dl_cm_revision,
       ddl.dl_cm_timestamp,
       ddl.mb_uuid AS dl_mb_uuid,
       ddl.mb_name AS dl_mb_name,
       ddl.mb_account AS dl_mb_account,
       ddl.dl_left,
       ddl.dl_left_from AS dl_left_from,
	   ddl.dl_right,
       ddl.dl_right_from AS dl_right_from,
       ddl.dl_accepted_state AS dl_accepted_state,
       ddl.dl_accepted_by AS dl_accepted_by,
       ddl.dl_accepted_revision_left AS dl_accepted_revision_left,
       ddl.dl_accepted_revision_right AS dl_accepted_revision_right,
       ddl.dl_accepted_comment AS dl_accepted_comment,
       ddo.*
  FROM ds_ddl_na AS ddl
       INNER JOIN
       ds_ddo ddo ON (ddo.do_uuid = ddl.dl_left AND 
                      ddo.ds_uuid = ddl.ds_uuid) 
 WHERE ddl.dl_left_to = -1 AND 
       ddl.dl_right_to = -1;

CREATE VIEW ds_ddl_left_na AS SELECT ddl.ds_uuid,
       ddl.dl_uuid,
       ddl.dl_definition,
       ddl.dl_cm_revision,
       ddl.dl_cm_timestamp,
       ddl.dl_right,
       ddl.mb_uuid AS dl_mb_uuid,
       ddl.mb_name AS dl_mb_name,
       ddl.mb_account AS dl_mb_account,
       ddl.dl_left_from AS dl_left_from,
       ddl.dl_right_from AS dl_right_from,
       ddl.dl_accepted_state AS dl_accepted_state,
       ddl.dl_accepted_by AS dl_accepted_by,
       ddl.dl_accepted_revision_left AS dl_accepted_revision_left,
       ddl.dl_accepted_revision_right AS dl_accepted_revision_right, 
       ddl.dl_accepted_comment AS dl_accepted_comment,
       ddo.*
  FROM ds_ddl_na AS ddl
       INNER JOIN
       ds_ddo_na ddo ON (ddo.do_uuid = ddl.dl_left AND 
                         ddo.ds_uuid = ddl.ds_uuid) 
 WHERE ddl.dl_left_to = -1 AND 
       ddl.dl_right_to = -1;

CREATE VIEW ds_ddl_na AS SELECT dds.solution AS ds_uuid,
       dds.ddl AS dl_uuid,
       ddl.definition AS dl_definition,
       do_left AS dl_left,
       ddo_l.cm_revision AS dl_leftRevision,
       dds.left_from AS dl_left_from,
       dds.left_to AS dl_left_to,
       do_right AS dl_right,
       ddo_r.cm_revision AS dl_right_revision,
       dds.right_from AS dl_right_from,
       dds.right_to AS dl_right_to,
       rpm.uuid AS mb_uuid,
       rpm.name AS mb_name,
       rpm.account AS mb_account,
       dds.cm_revision AS dl_cm_revision,
       dds.accepted_by AS dl_accepted_by,
       dds.accepted_revision_left AS dl_accepted_revision_left,
       dds.accepted_revision_right AS dl_accepted_revision_right,
       dds.accepted_state AS dl_accepted_state,
       dds.accepted_comment AS dl_accepted_comment,
       dds.cm_timestamp AS dl_cm_timestamp,
       ddl.repository AS dl_repository
  FROM dd_link ddl
       INNER JOIN
       dd_ddl_solution dds ON (dds.ddl = ddl.uuid) 
       INNER JOIN
       dd_object ddo_l ON (ddo_l.uuid = ddl.do_left) 
       INNER JOIN
       dd_object ddo_r ON (ddo_r.uuid = ddl.do_right) 
       LEFT JOIN
       rp_member rpm ON (rpm.uuid = dds.cm_modified_by) 
 WHERE dds.left_to = -1;

CREATE VIEW ds_ddl_right AS SELECT ddl.ds_uuid,
       ddl.dl_uuid,
       ddl.dl_definition,
       ddl.dl_cm_revision,
       ddl.dl_cm_timestamp,
       ddl.mb_uuid AS dl_mb_uuid,
       ddl.mb_name AS dl_mb_name,
       ddl.mb_account AS dl_mb_account,
       ddl.dl_left,
       ddl.dl_left_from AS dl_left_from,
       ddl.dl_right,
       ddl.dl_right_from AS dl_right_from,
       ddl.dl_accepted_state AS dl_accepted_state,
       ddl.dl_accepted_by AS dl_accepted_by,
       ddl.dl_accepted_revision_left AS dl_accepted_revision_left,
       ddl.dl_accepted_revision_right AS dl_accepted_revision_right,
       ddl.dl_accepted_comment AS dl_accepted_comment,
       ddo.*
  FROM ds_ddl_na AS ddl
       INNER JOIN
       ds_ddo ddo ON (ddo.do_uuid = ddl.dl_right AND 
                      ddo.ds_uuid = ddl.ds_uuid) 
 WHERE ddl.dl_left_to = -1 AND 
       ddl.dl_right_to = -1;

CREATE VIEW ds_ddl_right_na AS SELECT ddl.ds_uuid,
       ddl.dl_uuid,
       ddl.dl_definition,
       ddl.dl_cm_revision,
       ddl.dl_cm_timestamp,
       ddl.dl_left,
       ddl.mb_uuid AS dl_mb_uuid,
       ddl.mb_name AS dl_mb_name,
       ddl.mb_account AS dl_mb_account,
       ddl.dl_left_from AS dl_left_from,
       ddl.dl_right_from AS dl_right_from,
       ddl.dl_accepted_state AS dl_accepted_state,
       ddl.dl_accepted_by AS dl_accepted_by,
       ddl.dl_accepted_revision_left AS dl_accepted_revision_left,
       ddl.dl_accepted_revision_right AS dl_accepted_revision_right, 
       ddl.dl_accepted_comment AS dl_accepted_comment,
       ddo.*
  FROM ds_ddl_na AS ddl
       INNER JOIN
       ds_ddo_na ddo ON (ddo.do_uuid = ddl.dl_right AND 
                         ddo.ds_uuid = ddl.ds_uuid) 
 WHERE ddl.dl_left_to = -1 AND 
       ddl.dl_right_to = -1;

CREATE VIEW ds_ddo AS SELECT ds.solution AS ds_uuid,
           da.ddo AS do_uuid,
           ddo.definition AS do_definition,
           ddo.localId AS do_local_id,
           ddo.cm_revision AS do_cm_revision,
           ddo.cm_timestamp AS do_cm_timestamp,
           ddo.cm_modified_by AS do_cm_modified_by,
           ddo.repository AS do_repository,
           rpm.uuid AS do_mb_uuid,
           rpm.name AS do_mb_name,
           rpm.account AS do_mb_account,
           ow.uuid AS do_ow_uuid,
           ow.name AS do_ow_name,
           rs.uuid AS do_rs_uuid,
           rs.name AS do_rs_name,
           dad.id AS da_id,
           da.dda AS da_uuid,
           da.value AS da_value
      FROM dd_attribute_value AS da
           INNER JOIN
           dd_def_attribute dad ON (dad.uuid=da.dda)
           LEFT JOIN
           cm_ddo cm ON (cm.ddo_uuid = da.ddo) 
           LEFT JOIN
           dd_object ddo ON (ddo.uuid = da.ddo) 
           LEFT JOIN
           dd_ddo_solution ds ON (ds.ddo = da.ddo) 
           LEFT JOIN
           po_ipt rs ON (rs.uuid = ds.responsible) 
           LEFT JOIN
           po_ipt ow ON (ow.uuid = ds.cm_owner) 
           LEFT JOIN
           rp_member rpm ON (rpm.uuid = ddo.cm_modified_by) 
     WHERE ds.revision_to == -1;

CREATE VIEW ds_ddo_all AS SELECT *
  FROM ds_ddo
UNION
SELECT *
  FROM ds_ddo_history;;

CREATE VIEW ds_ddo_ddl_left AS SELECT ddl.ds_uuid,
       ddl.dl_uuid,
       ddl.dl_definition,
       ddl.dl_cm_revision,
       ddl.dl_cm_timestamp,
       ddl.dl_right,
       ddl.mb_uuid AS dl_mb_uuid,
       ddl.mb_name AS dl_mb_name,
       ddl.mb_account AS dl_mb_account,
       ddl.dl_left_from AS dl_left_from,
       ddl.dl_right_from AS dl_right_from,
       ddl.dl_accepted_state AS dl_accepted_state,
       ddl.dl_accepted_by AS dl_accepted_by,
       ddl.dl_accepted_revision_left AS dl_accepted_revision_left,
       ddl.dl_accepted_revision_right AS dl_accepted_revision_right,
       ddl.dl_accepted_comment AS dl_accepted_comment,
       ddo.*
  FROM ds_ddo AS ddo
       LEFT JOIN
       ds_ddl_na ddl ON (ddo.do_uuid = ddl.dl_left AND 
                         ddo.ds_uuid = ddl.ds_uuid);

CREATE VIEW ds_ddo_ddl_right AS SELECT ddl.ds_uuid,
       ddl.dl_uuid,
       ddl.dl_definition,
       ddl.dl_cm_revision,
       ddl.dl_cm_timestamp,
       ddl.dl_left,
       ddl.mb_uuid AS dl_mb_uuid,
       ddl.mb_name AS dl_mb_name,
       ddl.mb_account AS dl_mb_account,
       ddl.dl_left_from AS dl_left_from,
       ddl.dl_right_from AS dl_right_from,
       ddl.dl_accepted_state AS dl_accepted_state,
       ddl.dl_accepted_by AS dl_accepted_by,
       ddl.dl_accepted_revision_left AS dl_accepted_revision_left,
       ddl.dl_accepted_revision_right AS dl_accepted_revision_right,
       ddl.dl_accepted_comment AS dl_accepted_comment,
       ddo.* 
  FROM ds_ddo AS ddo
       LEFT JOIN
       ds_ddl_na ddl ON (ddo.do_uuid = ddl.dl_right AND 
                         ddo.ds_uuid = ddl.ds_uuid);

CREATE VIEW ds_ddo_history AS SELECT ds.solution AS ds_uuid,
           da.ddo AS do_uuid,
           ddo.definition AS do_definition,
           ddo.localId AS do_local_id,
           ddo.cm_revision AS do_cm_revision,
           ddo.cm_timestamp AS do_cm_timestamp,
           ddo.cm_modified_by AS do_cm_modified_by,
           ddo.repository AS do_repository,
           rpm.uuid AS mb_uuid,
           rpm.name AS mb_name,
           rpm.account AS mb_account,
           ow.uuid AS ow_uuid,
           ow.name AS ow_name,
           rs.uuid AS rs_uuid,
           rs.name AS rs_name,
           dad.id AS da_id,
           da.dda AS da_uuid,
           da.value AS da_value 
      FROM dd_attribute_history AS da
           INNER JOIN
           dd_def_attribute dad ON (dad.uuid=da.dda)
           LEFT JOIN
           cm_ddo cm ON (cm.ddo_uuid = da.ddo) 
           LEFT JOIN
           dd_object_history ddo ON (ddo.uuid = da.ddo) 
           LEFT JOIN
           dd_ddo_solution ds ON (ds.ddo = da.ddo) 
           LEFT JOIN
           po_ipt rs ON (rs.uuid = ds.responsible) 
           LEFT JOIN
           po_ipt ow ON (ow.uuid = ds.cm_owner) 
           LEFT JOIN
           rp_member rpm ON (rpm.uuid = ddo.cm_modified_by) 
     WHERE ds.revision_to == -1;

CREATE VIEW ds_ddo_na AS SELECT dds.solution AS ds_uuid,
       ddo.uuid AS do_uuid,
       ddo.definition AS do_definition,
       ddo.localId AS do_local_id,
       dd.id || '-' || ddo.localId AS do_puid,
       ddo.cm_revision AS do_cm_revision,
       ddo.cm_timestamp AS do_cm_timestamp,
       ddo.repository AS do_repository,
       ow.uuid AS ow_uuid,
       ow.name AS ow_name,
       rs.uuid AS rs_uuid,
       rs.name AS rs_name
  FROM dd_ddo_solution AS dds
       INNER JOIN
       dd_object ddo ON (ddo.uuid = dds.ddo) 
       LEFT JOIN
       po_ipt ow ON (ow.uuid = dds.cm_owner) 
       LEFT JOIN
       po_ipt rs ON (rs.uuid = dds.responsible)
       INNER JOIN
       dd_def_object dd ON (dd.uuid=ddo.definition)
 WHERE dds.revision_to = -1;

CREATE VIEW ds_ddo_na_all AS SELECT *
  FROM ds_ddo_na
UNION
SELECT *
  FROM ds_ddo_na_history;

CREATE VIEW ds_ddo_na_history AS SELECT dds.solution AS ds_uuid,
       ddo.uuid AS do_uuid,
       ddo.definition AS do_definition,
       ddo.localId AS do_local_id,
       dd.id || '-' || ddo.localId AS do_puid,
       ddo.cm_revision AS do_cm_revision,
       ddo.cm_timestamp AS do_cm_timestamp,
       ddo.repository AS do_repository,
       ow.uuid AS ow_uuid,
       ow.name AS ow_name,
       rs.uuid AS rs_uuid,
       rs.name AS rs_name
  FROM dd_ddo_solution AS dds
       INNER JOIN
       dd_object_history ddo ON (ddo.uuid = dds.ddo) 
       LEFT JOIN
       po_ipt ow ON (ow.uuid = dds.cm_owner) 
       LEFT JOIN
       po_ipt rs ON (rs.uuid = dds.responsible)
       INNER JOIN
       dd_def_object dd ON (dd.uuid=ddo.definition)
 WHERE dds.revision_to = -1;

CREATE VIEW ha_assessments AS SELECT ast.uuid AS as_uuid,
	   ast.severity AS as_severity,
       ast.avoidance AS as_avoidance,
       ast.frequency AS as_ra_frequency,
       ast.probability AS as_ra_probability,
       mb.uuid AS as_mb_uuid,
       mb.account AS as_mb_account,
       mb.name AS as_mb_name,
       ast.cm_revision AS as_cm_revision,
       ast.cm_timestamp AS as_cm_timestamp,
       ast.repository AS as_rp_uuid
  FROM ha_assessment AS ast
       INNER JOIN
       rp_member mb ON (mb.uuid = ast.cm_modified_by)
 WHERE ast.cm_deleted = 0;

CREATE VIEW ha_hazard_assessments AS SELECT hz.solution AS ds_uuid,
       hz.uuid AS hz_uuid,
       hz.ddo AS do_uuid,
       hz.typeofhazard AS hz_type,
       hz.lifecyclephases AS hz_lifecyclephases,
       hz.description AS hz_description,
       hz.alarp AS hz_alarp,
       hzmb.uuid AS hz_mb_uuid,
       hzmb.account AS hz_mb_account,
       hzmb.name AS hz_mb_name,
       hz.cm_revision AS hz_cm_revision,
       hz.cm_timestamp AS hz_cm_timestamp,
       hz.repository AS rp_uuid,
       ast.uuid AS as_uuid,
       ast.severity AS as_severity,
       ast.avoidance AS as_avoidance,
       ast.frequency AS as_frequency,
       ast.probability AS as_probability,
       astmb.uuid AS as_mb_uuid,
       astmb.account AS as_mb_account,
       astmb.name AS as_mb_name,
       ast.cm_revision AS as_cm_revision,
       ast.cm_timestamp AS as_cm_timestamp,
       ast.repository AS as_rp_uuid
  FROM ha_hazard AS hz
       INNER JOIN
       rp_member hzmb ON (hzmb.uuid = hz.cm_modified_by) 
       INNER JOIN
       ha_hazard_assessment hha ON (hha.hazard = hz.uuid) 
       INNER JOIN
       ha_assessment ast ON (hha.assessment = ast.uuid) 
       INNER JOIN
       rp_member astmb ON (astmb.uuid = ast.cm_modified_by) 
 WHERE hz.cm_deleted = 0;

CREATE VIEW ha_hazards AS SELECT hz.solution AS ds_uuid,
       hz.uuid AS hz_uuid,
       hz.ddo AS do_uuid,
       hz.description AS hz_description,
       hz.lifecyclephases AS hz_lifecyclephases,
       hz.typeofhazard AS hz_type,
       hz.alarp AS hz_alarp,
       cm_revision AS cm_revision,
       mb.uuid AS mb_uuid,
       mb.account AS mb_account,
       mb.name AS mb_name,
       hz.repository AS rp_uuid
  FROM ha_hazard AS hz
       INNER JOIN
       rp_member mb ON (mb.uuid = hz.cm_modified_by) 
 WHERE cm_deleted = 0;

CREATE VIEW ha_mitigation_assessments AS SELECT hz.solution AS ds_uuid,
       hz.uuid AS hz_uuid,
       mn.uuid AS mn_uuid,
       mn.type AS mn_type,
       mn.description AS mn_description,
       mnmb.uuid AS mn_mb_uuid,
       mnmb.account AS mn_mb_account,
       mnmb.name AS mn_mb_name,
       mn.cm_revision AS mn_cm_revision,
       mn.cm_timestamp AS mn_cm_timestamp,
       mn.repository AS rp_uuid,
       ast.uuid AS as_uuid,
       ast.severity AS as_severity,
       ast.avoidance AS as_avoidance,
       ast.frequency AS as_frequency,
       ast.probability AS as_probability,
       astmb.uuid AS as_mb_uuid,
       astmb.account AS as_mb_account,
       astmb.name AS as_mb_name,
       ast.cm_revision AS as_cm_revision,
       ast.cm_timestamp AS as_cm_timestamp,
       ast.repository AS as_rp_uuid
  FROM ha_mitigation AS mn
       INNER JOIN ha_hazard hz ON (hz.uuid=mn.hazard)
       INNER JOIN
       rp_member mnmb ON (mnmb.uuid = mn.cm_modified_by) 
       INNER JOIN
       ha_mitigation_assessment hma ON (hma.mitigation = mn.uuid) 
       INNER JOIN
       ha_assessment ast ON (hma.assessment = ast.uuid) 
       INNER JOIN
       rp_member astmb ON (astmb.uuid = ast.cm_modified_by) 
 WHERE mn.cm_deleted = 0;

CREATE VIEW ip_assigned_members AS SELECT po.uuid AS po_uuid,
        ip.ipt AS ip_uuid,
       mb.account AS mb_account,
       mb.name AS mb_name,
       rpm.mode AS mb_mode,
       mb.radmin AS mb_radmin,
       mb.uuid AS mb_uuid,
       mb.repository AS mb_repository
  FROM rp_project po
       INNER JOIN
       rp_project_member rpm ON (po.uuid = rpm.project) 
       INNER JOIN
       rp_member mb ON (rpm.member = mb.uuid)
       INNER JOIN 
       po_ipt_member ip ON (ip.member=rpm.member);

CREATE VIEW mb_assigned_projects AS SELECT pim.member AS mb_uuid,
           rpm.mode AS mb_mode,
           rp.uuid AS po_uuid,
           rp.name AS po_name,
           rp.state AS po_state
      FROM po_ipt_member pim
           INNER JOIN
           rp_project_member rpm ON (pim.member=rpm.member AND pim.project=rpm.project) 
           INNER JOIN
           po_ipt pi ON (pim.ipt = pi.uuid) 
           INNER JOIN
           rp_project rp ON (pi.project = rp.uuid);

CREATE VIEW mb_assigned_roles AS SELECT ro.project AS po_uuid,
       mb.uuid AS mb_uuid,
       mb.account AS mb_account,
       mb.name AS mb_name,
       rpm.mode AS mb_mode,
       ro.uuid AS ro_uuid,
       ro.id AS ro_id,
       ro.state AS ro_state,
       ro.description AS ro_description
  FROM po_role AS ro
       INNER JOIN
       po_role_member rm ON (rm.role = ro.uuid) 
       INNER JOIN
       rp_project_member rpm ON (rpm.member = rm.member AND 
                                 rpm.project = ro.project) 
       INNER JOIN
       rp_member mb ON (mb.uuid = rpm.member);

CREATE VIEW mb_assigned_solutions AS SELECT po.uuid AS po_uuid,
       po.name AS po_name,
       po.state AS po_state,
       po.description AS po_description,
       po.properties AS po_properties,
       po.repository AS po_repository,
       so.uuid AS so_uuid,
       so.name AS so_name,
       so.description AS so_description,
       so.enabled AS so_enabled,
       so.readonly AS so_readonly,
       ap.mb_uuid,
       ap.mb_mode
  FROM mb_assigned_projects AS ap
       LEFT JOIN
       rp_solution_space AS so ON (so.project = ap.po_uuid) 
       INNER JOIN
       rp_project po ON (po.uuid = ap.po_uuid) 
 ORDER BY po_uuid;;

CREATE VIEW mb_assigned_teams AS SELECT rp.uuid AS po_uuid,
           pim.member AS mb_uuid,
           rpm.mode AS mb_mode,
           pi.uuid AS ip_uuid,           
           pi.name AS ip_name,
           pi.description AS ip_description,
           pi.type AS ip_type,
           pi.repository AS ip_repository
      FROM po_ipt_member pim
           INNER JOIN
           rp_project_member rpm ON (pim.member = rpm.member) 
           INNER JOIN
           po_ipt pi ON (pim.ipt = pi.uuid) 
           INNER JOIN
           rp_project rp ON (pi.project = rp.uuid);

CREATE VIEW mb_assigned_transactions AS SELECT po_role.project AS po_uuid,
       rp_transaction.uuid AS ta_uuid,
       rp_transaction.name AS ta_name,
       po_role.uuid AS ro_uuid,
       po_role.id AS ro_id,
       po_role.state AS ro_state,
       po_role.repository AS ro_repository,
       ro_assigned_teammembers.mb_uuid AS mb_uuid,
       ro_assigned_teammembers.mb_account AS mb_account,
       ro_assigned_teammembers.mb_mode AS mb_mode
  FROM po_role_transaction
       INNER JOIN
       po_role ON (po_role.uuid = po_role_transaction.role) 
       INNER JOIN
       rp_transaction ON (rp_transaction.uuid = po_role_transaction.transaction_uuid) 
       INNER JOIN
       ro_assigned_teammembers ON (ro_assigned_teammembers.ro_uuid = po_role.uuid);

CREATE VIEW mb_modifiedBy AS SELECT uuid AS mb_uuid,
       account AS mb_account,
       name AS mb_name
  FROM rp_member;

CREATE VIEW mm_ddh AS SELECT dh.project AS po_uuid,
       dh.uuid AS dh_uuid,
	   dh.id AS dh_id,
       dh.name AS dh_name,
       dh.up AS dl_up_uuid,
       dh.down AS dl_down_uuid,
       dh.repository AS rp_uuid
  FROM dd_def_hierarchy AS dh;

CREATE VIEW mm_ddl AS SELECT dl.project AS po_uuid,
           dl.[left] AS dl_left_uuid,
           dol.id AS dl_left_id,
           dl.id AS dl_id,
           dl.cardinality AS dl_cardinality,
           0 AS dl_hierarchy,
           dl.direction AS dl_direction,
           dl.reverse AS dl_reverse,
           dl.[right] AS dl_right_uuid,
           dor.id AS dl_right_id,
           dl.uuid AS dl_uuid,
           dl.repository AS dl_repository
      FROM dd_def_link dl
           LEFT JOIN
           dd_def_link_reverse dr ON (dr.foreward = dl.uuid) 
           INNER JOIN
           dd_def_object dol ON (dol.uuid = dl.[left]) 
           INNER JOIN
           dd_def_object dor ON (dor.uuid = dl.[right]);

CREATE VIEW mm_ddo AS SELECT dd.project AS po_uuid,
       dd.id AS do_id,
       dd.shareable AS do_shareable,
       dd.uuid AS do_uuid,
       dd.icon AS do_icon,
       dd.properties AS do_properties,
       dd.rules AS do_rules,
       da.uuid AS da_uuid,
       da.id AS da_id,
       da.type AS da_type,
       da.properties AS da_properties,
       da.unit AS da_unit,
       da.precision AS da_precision,
       da.decimals AS da_decimals,
       da.enums AS da_enumeration,
       da.defaultValue AS da_defaultvalue,
       da.sortOrder AS da_sortOrder,
       da.repository AS da_repository
  FROM dd_def_object dd
       INNER JOIN
       dd_def_attribute da ON (da.ddo = dd.uuid) 
 ORDER BY po_uuid,
          do_uuid,
          da_sortOrder;

CREATE VIEW mm_enum AS SELECT dde.dda AS da_uuid,
       tr.code AS tr_code,
       dde.uuid AS en_uuid,
       dde.ekey AS en_key,
       dde.properties AS en_properties,
       tr.translation AS en_value
  FROM dd_def_enum AS dde
       LEFT JOIN
       sp_translation tr ON (tr.uuid = dde.uuid);

CREATE VIEW ow_ipt AS SELECT uuid AS ow_uuid,
       name AS ow_name,
       description AS ow_description,
       type AS ow_type,
       repository AS ow_repository
  FROM po_ipt;

CREATE VIEW po_assigned_ddo AS SELECT rps.project AS po_uuid,
       rps.uuid AS ds_uuid,
       ds.ddo AS do_uuid
  FROM dd_ddo_solution AS ds
       LEFT JOIN
       rp_solution_space rps ON (rps.uuid = ds.solution) 
       LEFT JOIN
       rp_project rpp ON (rpp.uuid = rps.project) 
 WHERE ds.revision_to == -1;

CREATE VIEW po_ddo_templates AS SELECT dd.project AS po_uuid,
       dd.uuid AS do_uuid,
       te.uuid AS te_uuid,
       te.id AS te_id,
       te.category AS te_category,
       te.template AS te_template,
       te.repository AS te_repository
  FROM dd_def_object AS dd
       INNER JOIN
       dd_template te ON (te.uuid = dd.uuid);

CREATE VIEW po_ipts AS SELECT ip.uuid AS ip_uuid,
           ip.name AS ip_name,
           ip.description AS ip_description,
           ip.type AS ip_type,
           ip.project AS po_uuid
      FROM po_ipt ip;;

CREATE VIEW po_members AS SELECT po.uuid AS po_uuid,
       mb.account AS mb_account,
       mb.name AS mb_name,
       mb.email AS mb_email,
       mb.phone AS mb_phone,
       mb.locked AS mb_locked,
       rpm.mode = 'readonly' AS mb_readonly,
       rpm.mode AS mb_mode,
       mb.radmin AS mb_radmin,
       mb.uuid AS mb_uuid,
       mb.repository AS mb_repository
  FROM rp_project po
       INNER JOIN
       rp_project_member rpm ON (po.uuid = rpm.project) 
       INNER JOIN
       rp_member mb ON (rpm.member = mb.uuid);

CREATE VIEW re_document_reportson AS SELECT ro.document AS dt_uuid,
       ddo.*
  FROM re_reportson AS ro
       LEFT JOIN
       ds_ddo ddo ON (ro.object = ddo.do_uuid);

CREATE VIEW re_documents AS SELECT dt.solution AS ds_uuid,
       dt.uuid AS dt_uuid,
       dt.category AS dt_category,
       dt.documentNumber AS dt_documentNumber,
       dt.title AS dt_title,
       dt.revisionNumber AS dt_revisionNumber,
       dt.publicationDate AS dt_publicationDate,
       dt.layout AS dt_layout,
       dt.dmsUrl AS dt_dmsUrl,
       dt.ismsClassification AS dt_ismsClassification,
       dt.govClassification AS dt_govClassification,
       dt.lang AS dt_lang,
       dt.template AS dt_template,
       dt.properties AS dt_properties,
       dt.cm_revision AS dt_cm_revision,
       mb.*,
       ow.*
  FROM re_document AS dt
       LEFT JOIN
       ow_ipt ow ON (ow.ow_uuid = dt.cm_owner) 
       LEFT JOIN
       mb_modifiedBy mb ON (mb.mb_uuid = dt.cm_modified_by) 
 WHERE dt.cm_deleted = 0;;

CREATE VIEW re_documents_history AS SELECT dt.solution AS ds_uuid,
       dt.uuid AS dt_uuid,
       dt.category AS dt_category,
       dt.documentNumber AS dt_documentNumber,
       dt.title AS dt_title,
       dt.revisionNumber AS dt_revisionNumber,
       dt.publicationDate AS dt_publicationDate,
       dt.layout AS dt_layout,
       dt.dmsUrl AS dt_dmsUrl,
       dt.ismsClassification AS dt_ismsClassification,
       dt.govClassification AS dt_govClassification,
       dt.lang AS dt_lang,
       dt.template AS dt_template,
       dt.properties AS dt_properties,
       dt.cm_revision AS dt_cm_revision,
       mb.*,
       ow.*
  FROM re_document_history AS dt
      LEFT JOIN
      ow_ipt ow ON (ow.ow_uuid = dt.cm_owner)
      LEFT JOIN
      mb_modifiedBy mb ON (mb.mb_uuid = dt.cm_modifiedBy);

CREATE VIEW re_layouts AS SELECT lt.solution AS ds_uuid,
       lt.uuid AS lt_uuid,
       lt.name AS lt_name,
       lt.description AS lt_description,
       (
           SELECT GROUP_CONCAT(rf.rf_id) 
             FROM re_reportformats AS rf
            WHERE rf.lt_uuid = lt.uuid
       )
       AS lt_formats,
       mb.mb_account AS lt_mb_account,
       mb.mb_name AS lt_mb_name,
       mb.mb_uuid AS lt_mb_uuid,
       lt.cm_revision AS lt_cm_revision,
       lt.cm_timestamp AS lt_cm_timestamp,
       lt.cm_modified_by AS lt_cm_modified_by,
       lt.repository AS lt_repository
  FROM re_layout AS lt
       LEFT JOIN
       mb_modifiedBy mb ON (mb.mb_uuid = lt.cm_modified_by) 
 WHERE cm_deleted = 0;;

CREATE VIEW re_reportformats AS SELECT layout AS lt_uuid,
       format AS rf_id,
       enabled AS rf_enabled,
       data AS rf_data
  FROM re_reportformat;

CREATE VIEW re_sections AS SELECT sn.document AS dt_uuid,
       sn.uuid AS sn_uuid,
       sn.number AS sn_number,
       sn.caption AS sn_caption,
       sn.description AS sn_description,
       st.uuid AS st_uuid,
       st.name AS st_name,
       sn.options AS st_options,
       sn.cm_timestamp AS cm_timestamp,
       sn.cm_revision AS cm_revision,
       mb.*,
       ow.*
  FROM re_section AS sn
       LEFT JOIN
       ow_ipt ow ON (ow.ow_uuid = sn.cm_owner) 
       LEFT JOIN
       mb_modifiedBy mb ON (mb.mb_uuid = sn.cm_modified_by) 
       LEFT JOIN
       sp_script st ON (st.uuid = sn.script) 
 WHERE sn.cm_deleted = 0;

CREATE VIEW re_sections_history AS SELECT sn.document AS dt_uuid,
       sn.uuid AS sn_uuid,
       sn.number AS sn_number,
       sn.caption AS sn_caption,
       sn.description AS sn_description,
       st.uuid AS st_uuid,
       st.name AS st_name,
       sn.options AS st_options,
       sn.cm_timestamp AS cm_timestamp,
       sn.cm_revision AS cm_revision,
       mb.*,
       ow.*
  FROM re_section_history AS sn
       LEFT JOIN
       ow_ipt ow ON (ow.ow_uuid = sn.cm_owner) 
       LEFT JOIN
       mb_modifiedBy mb ON (mb.mb_uuid = sn.cm_modified_by) 
       LEFT JOIN
       sp_script st ON (st.uuid = sn.script) 
 WHERE sn.cm_deleted = 0;

CREATE VIEW re_templates AS SELECT tes.solution AS ds_uuid,
       te.uuid AS te_uuid,
       te.id AS te_id,
       te.definition AS te_definition,
       te.timestamp AS te_timestamp,
       te.repository AS te_repository
  FROM re_template_solution AS tes
       LEFT JOIN
       re_template te ON (te.uuid = tes.template);

CREATE VIEW ro_assigned_teammembers AS SELECT rp_project_member.project AS po_uuid,
       po_role.uuid AS ro_uuid,
       po_role.id AS ro_id,
       po_role.description AS ro_description,
       po_role.state AS ro_state,
       po_role.repository AS ro_repository,
       rp_member.uuid AS mb_uuid,
       rp_member.account AS mb_account,
       rp_member.name AS mb_name,
       rp_project_member.mode AS mb_mode,
       rp_member.repository AS mb_repository
  FROM po_role_member
       INNER JOIN
       po_role ON (po_role.uuid = po_role_member.role) 
       INNER JOIN
       rp_project_member ON (rp_project_member.member = po_role_member.member) 
       INNER JOIN
       rp_member ON (rp_member.uuid = rp_project_member.member);

CREATE VIEW rp_members AS SELECT mb.account AS mb_account,
       mb.name AS mb_name,
       mb.radmin AS mb_radmin,
       mb.uuid AS mb_uuid,
	   mb.password AS mb_passwd,
       mb.locked AS mb_locked,
       mb.repository AS mb_repository
  FROM rp_member mb;

CREATE VIEW rp_projects AS SELECT uuid AS po_uuid,
       name AS po_name,
       state AS po_state,
       description AS po_description,
       properties AS po_properties,
       repository AS rp_uuid
  FROM rp_project;;

CREATE VIEW rp_solutions AS SELECT project AS po_uuid,
       uuid AS ds_uuid,
       name AS ds_name,
       description AS ds_description,
       enabled AS ds_enabled,
       readonly AS ds_readoly,
       repository AS rp_uuid
  FROM rp_solution_space;;

CREATE VIEW sn_ddl AS SELECT dds.solution AS ds_uuid,
       dds.ddl AS dl_uuid,
       ddl.definition AS dl_definition,
       do_left AS dl_left,
       ddo_l.cm_revision AS dl_left_cm_revision,
       dds.left_from AS dl_left_from,
       dds.left_to AS dl_left_to,
       do_right AS dl_right,
       ddo_r.cm_revision AS dl_right_crm_evision,
       dds.right_from AS dl_right_from,
       dds.right_to AS dl_right_to,
       dds.cm_modified_by AS dl_cm_modified_by,
       dds.cm_revision AS dl_cm_revision,
       dds.accepted_by AS dl_accepted_by,
       dds.accepted_revision_left AS dl_accepted_revision_left,
       dds.accepted_revision_right AS dl_accepted_revision_right,
       dds.accepted_state AS dl_accepted_state,
       dds.cm_timestamp AS dl_cm_timestamp,
       ddl.repository AS dl_repository
  FROM dd_link ddl
       INNER JOIN
       dd_ddl_solution dds ON (dds.ddl = ddl.uuid) 
       INNER JOIN
       dd_object ddo_l ON (ddo_l.uuid = ddl.do_left) 
       INNER JOIN
       dd_object ddo_r ON (ddo_r.uuid = ddl.do_right);

CREATE VIEW sp_issues AS SELECT ie.solution AS ds_uuid,
       ie.uuid AS ie_uuid,
       ie.title AS ie_title,
       ie.description AS ie_description,
       ie.degree_of_completion AS ie_degree_of_completion,
       ie.start_date AS ie_start_date,
       ie.due_date AS ie_due_date,
       ie.date_of_completion AS ie_date_of_completion,
       ie.state AS ie_state,
       ie.priority AS ie_priority,
       ie.responsible AS ie_responsible,
       ie.tracker AS ie_tracker,
       ie.workflow AS ie_workflow,
       ie.dd_type AS ie_dd_type,
       ie.dd_uuid AS ie_dd_uuid,
       ddo.do_uuid AS do_uuid,
       ddo.do_puid AS do_puid,
       ow.uuid AS ie_ow_uuid,
       ow.account AS ie_ow_account,
       ow.name AS ie_ow_name,
       rs.uuid AS ie_rs_uuid, 
       rs.account AS ie_rs_account,
       rs.name AS ie_rs_name,
       ie.cm_revision AS ie_cm_revision,
       ie.cm_timestamp AS ie_cm_timestamp,
       ie.cm_modified_by AS ie_cm_modified_by
  FROM sp_issue AS ie
       LEFT JOIN
       rp_member ow ON (ow.uuid=ie.cm_owner) 
       LEFT JOIN
       rp_member rs ON (rs.uuid = ie.responsible) 
       LEFT JOIN
       ds_ddo_na ddo ON (ie.dd_type = 'ddo' AND 
                      ie.dd_uuid = ddo.do_uuid)
WHERE ie.cm_deleted=0;

CREATE VIEW sp_scripts AS SELECT st.domain AS st_domain,
       st.uuid AS st_uuid,
       st.type AS st_type,
       st.name AS st_name,
       st.code AS st_code,
       st.cm_revision AS st_cm_revision,
       st.cm_timestamp AS st_cm_timestamp,
       mb.*
  FROM sp_script AS st
       LEFT JOIN
       mb_modifiedBy mb ON (mb.mb_uuid = st.cm_modified_by) 
 WHERE st.cm_deleted = 0;

CREATE VIEW ta_assignments AS SELECT po_role.project AS po_uuid,
       rp_transaction.uuid AS ta_uuid,
       rp_transaction.name AS ta_name,
       po_role.uuid AS ro_uuid,
       po_role.id AS ro_id,
       po_role.state AS ro_state,
       po_role.repository AS ro_repository,
       ro_assigned_teammembers.mb_uuid AS mb_uuid,
       ro_assigned_teammembers.mb_account AS mb_account,
       ro_assigned_teammembers.mb_mode AS mb_mode
  FROM po_role_transaction
       INNER JOIN
       po_role ON (po_role.uuid = po_role_transaction.role) 
       INNER JOIN
       rp_transaction ON (rp_transaction.uuid = po_role_transaction.transaction_uuid) 
       INNER JOIN
       ro_assigned_teammembers ON (ro_assigned_teammembers.ro_uuid = po_role.uuid);

CREATE VIEW tl_ddo AS SELECT IFNULL(ddo.da_value != (
                                  SELECT da_value
                                    FROM ds_ddo_history AS ddh
                                   WHERE ddh.do_uuid = ddo.do_uuid AND 
                                         ddh.da_uuid = ddo.da_uuid AND 
                                         ddh.do_cm_revision = (ddo.do_cm_revision - 1) 
                              ), 0) AS da_modified,
       *
  FROM ds_ddo AS ddo
UNION ALL
SELECT IFNULL(ddo.da_value != (
                                  SELECT da_value
                                    FROM ds_ddo_history AS ddh
                                   WHERE ddh.do_uuid = ddo.do_uuid AND 
                                         ddh.da_uuid = ddo.da_uuid AND 
                                         ddh.do_cm_revision = (ddo.do_cm_revision - 1) 
                              ), 0) AS da_modified,
       *
  FROM ds_ddo_history AS ddo
 ORDER BY do_cm_revision DESC;

CREATE VIEW tl_ddo_na AS SELECT *
  FROM ds_ddo_na_history
UNION
SELECT *
  FROM ds_ddo_na;

CREATE VIEW tl_documents AS SELECT *
  FROM re_documents_history
UNION ALL
SELECT *
  FROM re_documents
ORDER BY dt_uuid, dt_cm_revision;

CREATE VIEW tl_section AS SELECT *
  FROM re_sections_history
UNION ALL
SELECT *
  FROM re_sections
 ORDER BY sn_uuid,
          cm_revision;

CREATE VIEW tr_da_title AS SELECT group_concat(key || ':' || translation,',') AS translation FROM sp_translation 
WHERE
code = 'de-DE'
AND uuid='{5f5bd949-c8c8-4e74-960b-e30bd7ff4d18}';

CREATE TRIGGER tg_dd_object_ai AFTER INSERT ON dd_object FOR EACH ROW BEGIN UPDATE dd_objectid SET nextId=nextId+1 WHERE ddo=NEW.definition; END

CREATE TRIGGER tg_dd_object_bu BEFORE UPDATE ON dd_object FOR EACH ROW BEGIN INSERT OR REPLACE INTO dd_object_history SELECT * FROM dd_object WHERE uuid=OLD.uuid; END

CREATE TRIGGER tg_dm_diagram_au
         AFTER UPDATE OF name,
                         properties,
                         cm_modified_by,
                         cm_deleted
            ON dm_diagram
      FOR EACH ROW
BEGIN
    UPDATE dm_diagram
       SET cm_revision = cm_revision + 1,
           cm_timestamp = CURRENT_TIMESTAMP
     WHERE uuid = OLD.uuid;
END;

CREATE TRIGGER tg_dm_diagram_bu
        BEFORE UPDATE OF name,
                         properties,
                         cm_deleted
            ON dm_diagram
      FOR EACH ROW
BEGIN
    INSERT OR REPLACE INTO dd_diagram_history SELECT *
                                                FROM dm_diagram
                                               WHERE uuid = OLD.uuid;
END;

CREATE TRIGGER tg_dm_item_au
         AFTER UPDATE OF properties,
                         revision_to,
                         ghost
            ON dm_item
BEGIN
    UPDATE dm_item
       SET cm_revision = cm_revision + 1,
           cm_timestamp = CURRENT_TIMESTAMP
     WHERE uuid = OLD.uuid;
END;

CREATE TRIGGER tg_dm_item_bu
        BEFORE UPDATE OF properties,
                         revision_to,
                         ghost,
                         cm_modified_by
            ON dm_item
BEGIN
    INSERT OR REPLACE INTO dm_item_history SELECT *
                                             FROM dm_item
                                            WHERE uuid = OLD.uuid;
END;

CREATE TRIGGER tg_ha_assessment_au
         AFTER UPDATE OF type,
                         description,
                         severity,
                         avoidance,
                         frequency,
                         probability,
                         cm_deleted,
                         cm_modified_by
            ON ha_assessment
      FOR EACH ROW
BEGIN
    UPDATE ha_assessment
       SET cm_revision = cm_revision + 1,
           cm_timestamp = CURRENT_TIMESTAMP
     WHERE uuid = OLD.uuid;
END;

CREATE TRIGGER tg_ha_assessment_bu
        BEFORE UPDATE OF type,
                         description,
                         severity,
                         avoidance,
                         frequency,
                         probability,
                         cm_deleted
            ON ha_assessment
      FOR EACH ROW
BEGIN
    INSERT OR REPLACE INTO ha_assessment_history SELECT *
                                                   FROM ha_assessment
                                                  WHERE uuid = OLD.uuid;
END;

CREATE TRIGGER tg_ha_hazard_au
         AFTER UPDATE OF lifecyclephases,
                         typeofhazard,
                         description,
                         alarp,
                         cm_deleted
            ON ha_hazard
      FOR EACH ROW
BEGIN
    UPDATE ha_hazard
       SET cm_revision = cm_revision + 1,
           cm_timestamp = CURRENT_TIMESTAMP
     WHERE uuid = OLD.uuid;
END;

CREATE TRIGGER tg_ha_hazard_bu
        BEFORE UPDATE OF lifecyclephases,
                         typeofhazard,
                         description,
                         alarp,
                         cm_deleted,
                         cm_modified_by
            ON ha_hazard
      FOR EACH ROW
BEGIN
    INSERT OR REPLACE INTO ha_hazard_history SELECT *
                                               FROM ha_hazard
                                              WHERE uuid = OLD.uuid;
END;

CREATE TRIGGER tg_ha_mitigation_au
         AFTER UPDATE OF type,
                         description,
                         cm_deleted
            ON ha_mitigation
      FOR EACH ROW
BEGIN
    UPDATE ha_mitigation
       SET cm_revision = cm_revision + 1,
           cm_timestamp = CURRENT_TIMESTAMP
     WHERE uuid = OLD.uuid;
END;

CREATE TRIGGER tg_ha_mitigation_bu
        BEFORE UPDATE OF type,
                         description,
                         cm_deleted,
                         cm_modified_by
            ON ha_mitigation
      FOR EACH ROW
BEGIN
    INSERT OR REPLACE INTO ha_mitigation_history SELECT *
                                                   FROM ha_mitigation
                                                  WHERE uuid = OLD.uuid;
END;

CREATE TRIGGER tg_re_document_au
         AFTER UPDATE OF documentNumber,
                         title,
                         revisionNumber,
                         publicationDate,
                         category,
                         dmsUrl,
                         ismsClassification,
                         govClassification,
                         lang,
                         layout,
                         template,
                         properties,
                         cm_owner,
                         cm_deleted
            ON re_document
      FOR EACH ROW
BEGIN
    UPDATE re_document
       SET cm_revision = cm_revision + 1,
           cm_timestamp = CURRENT_TIMESTAMP
     WHERE uuid = OLD.uuid;
END;

CREATE TRIGGER tg_re_document_bu
        BEFORE UPDATE OF documentNumber,
                         title,
                         revisionNumber,
                         publicationDate,
                         category,
                         dmsUrl,
                         ismsClassification,
                         govClassification,
                         lang,
                         layout,
                         template,
                         properties,
                         cm_deleted
            ON re_document
BEGIN
    INSERT OR REPLACE INTO re_document_history SELECT *
                                                 FROM re_document
                                                WHERE uuid = OLD.uuid;
END;

CREATE TRIGGER tg_re_section_au
         AFTER UPDATE OF number,
                         caption,
                         description,
                         script,
                         options,
                         cm_owner,
                         cm_deleted
            ON re_section
      FOR EACH ROW
BEGIN
    UPDATE re_section
       SET cm_revision = cm_revision + 1,
           cm_timestamp = CURRENT_TIMESTAMP
     WHERE uuid = OLD.uuid;
END;

CREATE TRIGGER tg_re_section_bu
        BEFORE UPDATE OF number,
                         caption,
                         description,
                         script,
                         options,
                         cm_owner,
                         cm_deleted
            ON re_section
BEGIN
    INSERT OR REPLACE INTO re_section_history SELECT *
                                                FROM re_section
                                               WHERE uuid = OLD.uuid;
END;

CREATE TRIGGER tg_sp_issue_au
        BEFORE UPDATE OF title,
                         description,
                         degree_of_completion,
                         start_date,
                         due_date,
                         date_of_completion,
                         state,
                         priority,
                         responsible,
                         cm_owner,
                         cm_modified_by
            ON sp_issue
BEGIN
    INSERT OR REPLACE INTO sp_issue_history SELECT *
                                              FROM sp_issue
                                             WHERE uuid = OLD.uuid;
END;

CREATE TRIGGER tg_sp_issue_bu
        BEFORE UPDATE OF title,
                         description,
                         degree_of_completion,
                         start_date,
                         due_date,
                         date_of_completion,
                         state,
                         priority,
                         responsible,
                         cm_owner,
                         cm_modified_by,
                         cm_deleted
            ON sp_issue
BEGIN
    INSERT OR REPLACE INTO sp_issue_history SELECT *
                                              FROM sp_issue
                                             WHERE uuid = OLD.uuid;
END;

CREATE TRIGGER tg_sp_script_au
         AFTER UPDATE OF name,
                         code
            ON sp_script
BEGIN
    UPDATE sp_script
       SET cm_revision = cm_revision + 1,
           cm_timestamp = CURRENT_TIMESTAMP
     WHERE uuid = OLD.uuid;
END;

