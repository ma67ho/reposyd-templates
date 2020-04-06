--
-- This patch file contains the changes related to the implementation
--- of the configuration management capabilities
--

BEGIN TRANSACTION;

PRAGMA foreign_keys = 0;

-- table cm_baseline_solution is obsolete
DROP TABLE IF EXISTS cm_baseline_solution;

CREATE TABLE sqlitestudio_temp_table AS SELECT *
                                          FROM cm_baseline;

DROP TABLE IF EXISTS cm_baseline;

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


INSERT INTO cm_baseline (
                            uuid,
                            name,
                            description,
                            major,
                            minor,
                            type,
                            cm_timestamp,
                            repository
                        )
                        SELECT uuid,
                               name,
                               description,
                               major,
                               minor,
                               type,
                               timestamp,
                               repository
                          FROM sqlitestudio_temp_table;

DROP TABLE sqlitestudio_temp_table;

PRAGMA foreign_keys = 1;

DROP VIEW cm_baselines;

CREATE VIEW cm_baselines AS
    SELECT bl.dsuuid AS ds_uuid,
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
		   

DROP TABLE IF EXISTS cm_document;

CREATE TABLE cm_document ( 
	bl_uuid              char(38) NOT NULL    ,
	dt_uuid              char(38) NOT NULL    ,
	dt_revision          integer NOT NULL    ,
	sn_uuid              char(38) NOT NULL    ,
	sn_revision          integer NOT NULL    ,
	FOREIGN KEY ( bl_uuid ) REFERENCES cm_baseline( uuid ) ON DELETE CASCADE 
 );

CREATE INDEX Idx_cm_document ON cm_document ( bl_uuid, dt_uuid );

DROP TABLE IF EXISTS cm_mitigation_assessments;

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


DROP TABLE IF EXISTS cm_hazard_assessment;

CREATE TABLE cm_hazard_assessment ( 
	bl_uuid              char(38) NOT NULL    ,
	hz_uuid              char(38) NOT NULL    ,
	hz_revision          integer NOT NULL    ,
	as_uuid              char(38) NOT NULL    ,
	as_revision          integer NOT NULL    ,
	CONSTRAINT idx_cm_hazard UNIQUE ( bl_uuid, hz_uuid, hz_revision, as_uuid, as_revision ) ,
	FOREIGN KEY ( bl_uuid ) REFERENCES cm_baseline( uuid ) ON DELETE CASCADE 
 );

DROP TABLE IF EXISTS cm_ddl;

CREATE TABLE cm_ddl ( 
	bl_uuid              char(38) NOT NULL    ,
	dl_uuid              char(38) NOT NULL    ,
	dl_revision          integer NOT NULL    ,
	FOREIGN KEY ( bl_uuid ) REFERENCES cm_baseline( uuid ) ON DELETE CASCADE 
 );

CREATE INDEX Idx_cm_ddl ON cm_ddl ( bl_uuid, dl_uuid );


DROP TABLE IF EXISTS cm_ddo;

CREATE TABLE cm_ddo ( 
	bl_uuid              char(38) NOT NULL    ,
	do_uuid              char(38) NOT NULL    ,
	do_revision          integer NOT NULL    ,
	FOREIGN KEY ( bl_uuid ) REFERENCES cm_baseline( uuid ) ON DELETE CASCADE 
 );

CREATE INDEX Idx_cm_ddo ON cm_ddo ( bl_uuid, do_uuid );


DROP TABLE IF EXISTS cm_diagram;

CREATE TABLE cm_diagram ( 
	bl_uuid              char(38) NOT NULL    ,
	dm_uuid              char(38) NOT NULL    ,
	cm_revision          integer NOT NULL    ,
	di_uuid              char(38) NOT NULL    ,
	di_revision          integer NOT NULL    ,
	FOREIGN KEY ( bl_uuid ) REFERENCES cm_baseline( uuid ) ON DELETE CASCADE 
 );

CREATE INDEX Idx_cm_diagram ON cm_diagram ( bl_uuid, dm_uuid, cm_revision, di_uuid, di_revision );



DROP VIEW dm_items;

CREATE VIEW dm_items AS
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
     WHERE di.revision_to = -1;

--
DROP TABLE IF EXISTS cm_request_solution;

PRAGMA foreign_keys = 0;

CREATE TABLE sqlitestudio_temp_table AS SELECT *
                                          FROM cm_request;

DROP TABLE cm_request;

CREATE TABLE cm_request (
    uuid        CHAR (38)     NOT NULL
                              PRIMARY KEY,
    dsuuid      CHAR (38),
    description TEXT,
    state       VARCHAR (100) NOT NULL
                              DEFAULT 'invalid',
    repository  CHAR (38),
    FOREIGN KEY (
        dsuuid
    )
    REFERENCES rp_solution_space (uuid) ON DELETE CASCADE
                                        ON UPDATE CASCADE
);

INSERT INTO cm_request (
                           uuid,
                           dsuuid,
                           description,
                           state,
                           repository
                       )
                       SELECT uuid,
                              dsuuid,
                              description,
                              state,
                              repository
                         FROM sqlitestudio_temp_table;

DROP TABLE sqlitestudio_temp_table;

PRAGMA foreign_keys = 1;

--
-- additional views
--
CREATE VIEW ds_ddo_na_all AS
    SELECT *
      FROM ds_ddo_na
    UNION
    SELECT *
      FROM ds_ddo_na_history;

CREATE VIEW ds_ddo_all AS
    SELECT *
      FROM ds_ddo
    UNION
    SELECT *
      FROM ds_ddo_history;

-- other tables
PRAGMA foreign_keys = 0;

CREATE TABLE sqlitestudio_temp_table AS SELECT *
                                          FROM dd_ddo_solution;

DROP TABLE dd_ddo_solution;

CREATE TABLE dd_ddo_solution (
    solution       CHAR (38) NOT NULL,
    ddo            CHAR (38) NOT NULL,
    revision_from  INTEGER   NOT NULL
                             DEFAULT -1,
    revision_to    INTEGER   NOT NULL
                             DEFAULT -1,
    cm_owner       CHAR (38),
    responsible    CHAR (38),
    cm_modified_by CHAR (38),
    cm_timestamp   DATETIME  DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_dd_visibility_ddo PRIMARY KEY (
        solution,
        ddo,
        revision_from,
        revision_to
    ),
    FOREIGN KEY (
        solution
    )
    REFERENCES rp_solution_space (uuid) ON DELETE CASCADE,
    FOREIGN KEY (
        ddo
    )
    REFERENCES dd_object (uuid),
    FOREIGN KEY (
        responsible
    )
    REFERENCES po_ipt (uuid) ON DELETE SET NULL
                             ON UPDATE CASCADE,
    FOREIGN KEY (
        cm_owner
    )
    REFERENCES po_ipt (uuid) ON DELETE SET NULL
                             ON UPDATE CASCADE
);

INSERT INTO dd_ddo_solution (
                                solution,
                                ddo,
                                revision_from,
                                revision_to,
                                cm_owner,
                                responsible,
                                cm_modified_by,
                                cm_timestamp
                            )
                            SELECT solution,
                                   ddo,
                                   revision_from,
                                   revision_to,
                                   cm_owner,
                                   responsible,
                                   cm_modified_by,
                                   cm_timestamp
                              FROM sqlitestudio_temp_table;

DROP TABLE sqlitestudio_temp_table;

CREATE INDEX idx_dd_ddo_solution_soluition ON dd_ddo_solution (
    solution
);

CREATE INDEX idx_dd_ddo_solution_modifiedBy ON dd_ddo_solution (
    cm_modified_by
);

CREATE INDEX idx_dd_ddo_solution_responsible ON dd_ddo_solution (
    responsible
);

CREATE INDEX idx_dd_ddo_solution_owner ON dd_ddo_solution (
    cm_owner
);

PRAGMA foreign_keys = 1;


-- set schema version number
INSERT OR REPLACE INTO rp_config (key,value) VALUES('schema/version', '0.4');
INSERT OR REPLACE INTO rp_config (key,value) VALUES('schema/patched', CURRENT_TIMESTAMP)
--
-- commit changes
--
COMMIT TRANSACTION;
