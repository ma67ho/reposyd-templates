--
-- This patch file contains the changes related to the implementation
--- of the configuration management capabilities
--

BEGIN TRANSACTION;


PRAGMA foreign_keys = 0;

DROP TABLE dd_ddl_solution_history;

CREATE TABLE dd_ddl_solution_history (
    solution                CHAR (38)     NOT NULL,
    ddl                     CHAR (38)     NOT NULL,
    left_from               INTEGER,
    left_to                 INTEGER,
    right_from              INTEGER,
    right_to                INTEGER,
    accepted_by             CHAR (38),
    accepted_revision_left  INTEGER       DEFAULT -1,
    accepted_revision_right INTEGER       DEFAULT -1,
    accepted_state          VARCHAR (100),
    accepted_comment        VARCHAR (255),
    cm_modified_by          CHAR (38),
    cm_revision             INTEGER,
    cm_timestamp            DATETIME      DEFAULT CURRENT_TIMESTAMP
);


CREATE INDEX idx_dd_variant_ddl_solution_0 ON dd_ddl_solution_history (
    solution
);

CREATE INDEX idx_dd_variant_ddl_dd_link_0 ON dd_ddl_solution_history (
    ddl
);

PRAGMA foreign_keys = 1;



DROP VIEW mb_assigned_solutions;

CREATE VIEW mb_assigned_solutions AS
    SELECT po.uuid AS po_uuid,
           po.name AS po_name,
           po.state AS po_state,
           po.description AS po_description,
           po.properties AS po_properties,
           po.repository AS po_repository,
           so.uuid AS ds_uuid,
           so.name AS ds_name,
           so.description AS so_description,
           so.enabled AS ds_enabled,
           so.readonly AS ds_readonly,
           ap.mb_uuid,
           ap.mb_mode
      FROM mb_assigned_projects AS ap
           LEFT JOIN
           rp_solution_space AS so ON (so.project = ap.po_uuid) 
           INNER JOIN
           rp_project po ON (po.uuid = ap.po_uuid) 
     ORDER BY po_uuid;

DROP VIEW mb_assigned_projects;

CREATE VIEW mb_assigned_projects AS
    SELECT rpm.member AS mb_uuid,
           rpm.mode AS mb_mode,
           rp.uuid AS po_uuid,
           rp.name AS po_name,
           rp.state AS po_state
      FROM rp_project_member AS rpm
           INNER JOIN
           rp_project rp ON (rpm.project = rp.uuid);

DROP VIEW rp_members;

CREATE VIEW rp_members AS
    SELECT mb.account AS mb_account,
           mb.email AS mb_email,
           mb.phone AS mb_phone,
           mb.name AS mb_name,
           mb.radmin AS mb_radmin,
           mb.uuid AS mb_uuid,
           mb.password AS mb_passwd,
           mb.locked AS mb_locked,
           mb.repository AS mb_repository
      FROM rp_member mb;


--
-- project templates
--
CREATE TABLE rp_template ( 
	uuid                 char(38) NOT NULL  PRIMARY KEY  ,
	id                   varchar(100) NOT NULL    ,
	definition           text  DEFAULT '{}'   ,
	cm_modified_by       char(38) NOT NULL    ,
	cm_revision          integer  DEFAULT 0   ,
	cm_timestamp         datetime NOT NULL DEFAULT CURRENT_TIMESTAMP   ,
	CONSTRAINT unq_rp_template_id UNIQUE ( id ) 
 );

DROP VIEW rp_solutions;

CREATE VIEW rp_solutions AS
    SELECT project AS po_uuid,
           uuid AS ds_uuid,
           name AS ds_name,
           description AS ds_description,
           enabled AS ds_enabled,
           readonly AS ds_readonly,
           repository AS rp_uuid
      FROM rp_solution_space;


-- triggers

CREATE TRIGGER tg_dd_ddl_solution_bu
        BEFORE UPDATE OF left_to,
                         right_to,
                         accepted_by,
                         accepted_revision_left,
                         accepted_revision_right,
                         accepted_state,
                         accepted_comment
            ON dd_ddl_solution
      FOR EACH ROW
BEGIN
    INSERT OR REPLACE INTO dd_ddl_solution_history SELECT *
                                                     FROM dd_ddl_solution
                                                    WHERE uuid = OLD.uuid;
END;

CREATE TRIGGER tg_dd_ddl_solution_au
         AFTER UPDATE OF left_to,
                         right_to,
                         accepted_by,
                         accepted_revision_left,
                         accepted_revision_right,
                         accepted_state,
                         accepted_comment
            ON dd_ddl_solution
      FOR EACH ROW
BEGIN
    UPDATE dd_ddl_solution
       SET cm_revision = cm_revision + 1,
           cm_timestamp = CURRENT_TIMESTAMP
     WHERE uuid = OLD.uuid;
END;
-- set schema version number
INSERT OR REPLACE INTO rp_config (key,value) VALUES('schema/version', '0.3');
INSERT OR REPLACE INTO rp_config (key,value) VALUES('schema/patched', CURRENT_TIMESTAMP)
--
-- commit changes
--
COMMIT TRANSACTION;

