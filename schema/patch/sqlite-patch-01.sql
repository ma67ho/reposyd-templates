PRAGMA foreign_keys = 0;

CREATE TABLE sqlitestudio_temp_table AS SELECT *
                                          FROM po_role_member;

DROP TABLE po_role_member;

CREATE TABLE po_role_member (
    project CHAR (38) NOT NULL,
    role    CHAR (38) NOT NULL,
    member  CHAR (38) NOT NULL,
    CONSTRAINT pk_po_role_member PRIMARY KEY (
        role,
        member,
        project
    ),
    FOREIGN KEY (
        project,
        role
    )
    REFERENCES po_role (project,
    uuid) ON DELETE CASCADE
);

INSERT INTO po_role_member (
                               project,
                               role,
                               member
                           )
                           SELECT project,
                                  role,
                                  member
                             FROM sqlitestudio_temp_table;

DROP TABLE sqlitestudio_temp_table;

CREATE INDEX idx_po_role_member ON po_role_member (
    role
);

CREATE INDEX idx_po_role_member_0 ON po_role_member (
    member
);


CREATE TABLE sqlitestudio_temp_table AS SELECT *
                                          FROM rp_project_member;

DROP TABLE rp_project_member;

CREATE TABLE rp_project_member (
    project CHAR (38)     NOT NULL,
    member  CHAR (38)     NOT NULL,
    mode    VARCHAR (100) DEFAULT readwrite,
    CONSTRAINT pk_po_project_member PRIMARY KEY (
        project,
        member
    ),
    FOREIGN KEY (
        member
    )
    REFERENCES rp_member (uuid) ON DELETE CASCADE,
    FOREIGN KEY (
        project
    )
    REFERENCES rp_project (uuid) ON DELETE CASCADE
);

INSERT INTO rp_project_member (
                                  project,
                                  member,
                                  mode
                              )
                              SELECT project,
                                     member,
                                     mode
                                FROM sqlitestudio_temp_table;

DROP TABLE sqlitestudio_temp_table;

CREATE INDEX idx_po_project_member_project ON rp_project_member (
    project
);

PRAGMA foreign_keys = 1;

DROP VIEW mb_assigned_projects;

CREATE VIEW mb_assigned_projects AS
    SELECT pim.member AS mb_uuid,
           rpm.mode AS mb_mode,
           rp.uuid AS po_uuid,
           rp.name AS po_name,
           rp.state AS po_state
      FROM po_ipt_member pim
           INNER JOIN
           rp_project_member rpm ON (pim.member = rpm.member AND 
                                     pim.project = rpm.project) 
           INNER JOIN
           po_ipt pi ON (pim.ipt = pi.uuid) 
           INNER JOIN
           rp_project rp ON (pi.project = rp.uuid);


-- change table sp_sys_log
ALTER TABLE sp_sys_log ADD category varchar(100);
ALTER TABLE sp_sys_log ADD originator varchar(38)    DEFAULT '<system>';

-- change tabe re_section_history
PRAGMA foreign_keys = 0;

CREATE TABLE sqlitestudio_temp_table AS SELECT *
                                          FROM re_section_history;

DROP TABLE re_section_history;

CREATE TABLE re_section_history (
    uuid           CHAR (38)     NOT NULL
                                 PRIMARY KEY,
    document       CHAR (38),
    number         VARCHAR (255),
    caption        VARCHAR (255),
    description    TEXT,
    script         VARCHAR (100),
    options        BLOB,
    cm_modified_by CHAR (38),
    cm_owner       CHAR (38),
    cm_revision    INTEGER       DEFAULT 0,
    cm_deleted     BOOLEAN       DEFAULT false,
    cm_timestamp   DATETIME      DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO re_section_history (
                                   uuid,
                                   document,
                                   number,
                                   caption,
                                   description,
                                   script,
                                   options,
                                   cm_modified_by,
                                   cm_owner,
                                   cm_revision,
                                   cm_deleted,
                                   cm_timestamp
                               )
                               SELECT uuid,
                                      document,
                                      number,
                                      caption,
                                      description,
                                      script,
                                      options,
                                      cm_modified_by,
                                      cm_owner,
                                      cm_revision,
                                      cm_deleted,
                                      cm_timestamp
                                 FROM sqlitestudio_temp_table;

DROP TABLE sqlitestudio_temp_table;

CREATE INDEX idx_re_section_document_0 ON re_section_history (
    document
);

CREATE INDEX idx_re_section_script_0 ON re_section_history (
    script
);

-- update column script set name instead of uuid
UPDATE re_section_history set script = (SELECT name FROM sp_script WHERE uuid = re_section_history.script);

PRAGMA foreign_keys = 1;

-- change tabe re_section

PRAGMA foreign_keys = 0;

CREATE TABLE sqlitestudio_temp_table AS SELECT *
                                          FROM re_section;

DROP TABLE re_section;

CREATE TABLE re_section (
    uuid           CHAR (38)     NOT NULL
                                 PRIMARY KEY,
    document       CHAR (38),
    number         VARCHAR (255),
    caption        VARCHAR (255),
    description    TEXT,
    script         VARCHAR (100),
    options        BLOB,
    cm_modified_by CHAR (38),
    cm_owner       CHAR (38),
    cm_revision    INTEGER       DEFAULT 0,
    cm_deleted     BOOLEAN       DEFAULT false,
    cm_timestamp   DATETIME      DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (
        document
    )
    REFERENCES re_document (uuid) ON DELETE CASCADE
);

INSERT INTO re_section (
                           uuid,
                           document,
                           number,
                           caption,
                           description,
                           script,
                           options,
                           cm_modified_by,
                           cm_owner,
                           cm_revision,
                           cm_deleted,
                           cm_timestamp
                       )
                       SELECT uuid,
                              document,
                              number,
                              caption,
                              description,
                              script,
                              options,
                              cm_modified_by,
                              cm_owner,
                              cm_revision,
                              cm_deleted,
                              cm_timestamp
                         FROM sqlitestudio_temp_table;

DROP TABLE sqlitestudio_temp_table;

CREATE INDEX idx_re_section_document ON re_section (
    document
);

CREATE INDEX idx_re_section_script ON re_section (
    script
);

-- update column script set name instead of uuid before recreating triggers
UPDATE re_section set script = (SELECT name FROM sp_script WHERE uuid = re_section.script);

-- recreate triggers
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

PRAGMA foreign_keys = 1;

DROP VIEW re_sections;

-- update view re_sections
CREATE VIEW re_sections AS
    SELECT sn.document AS dt_uuid,
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
           sp_script st ON (st.name = sn.script) 
     WHERE sn.cm_deleted = 0;

-- add column domain to table sp_script
PRAGMA foreign_keys = 0;

CREATE TABLE sqlitestudio_temp_table AS SELECT *
                                          FROM sp_script;

DROP TABLE sp_script;

CREATE TABLE sp_script (
    uuid           CHAR (38),
    type           VARCHAR (100),
    domain         CHAR (38)     DEFAULT ('<global>'),
    name           VARCHAR (100),
    code           BLOB,
    cm_revision    INTEGER       DEFAULT 0,
    cm_timestamp   DATETIME      DEFAULT CURRENT_TIMESTAMP,
    cm_modified_by CHAR (38)     NOT NULL,
    cm_deleted     BOOLEAN       DEFAULT 0,
    CONSTRAINT uix_se_script_uuid UNIQUE (
        uuid
    ),
    CONSTRAINT unq_sp_script UNIQUE (
        type,
        domain,
        name
    )
);

INSERT INTO sp_script (
                          uuid,
                          type,
                          name,
                          code,
                          cm_revision,
                          cm_timestamp,
                          cm_modified_by,
                          cm_deleted
                      )
                      SELECT uuid,
                             type,
                             name,
                             code,
                             cm_revision,
                             cm_timestamp,
                             cm_modified_by,
                             cm_deleted
                        FROM sqlitestudio_temp_table;

DROP TABLE sqlitestudio_temp_table;

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

DROP TABLE sp_script_project;

PRAGMA foreign_keys = 1;

-- update view sp_scripts
DROP VIEW sp_scripts;

CREATE VIEW sp_scripts AS
    SELECT st.domain AS st_domain,
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

-- set schema version number
INSERT OR REPLACE INTO rp_config (key,value) VALUES('schema/version', '1');
INSERT OR REPLACE INTO rp_config (key,value) VALUES('schema/patched', CURRENT_TIMESTAMP)
