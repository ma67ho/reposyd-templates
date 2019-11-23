PRAGMA foreign_keys = 0;

CREATE TABLE sqlitestudio_temp_table AS SELECT *
                                          FROM dm_item;

DROP TABLE dm_item;

CREATE TABLE dm_item (
    uuid           CHAR (38)     NOT NULL
                                 PRIMARY KEY,
    diagram        CHAR (38)     NOT NULL,
    type           VARCHAR (255),
    properties     TEXT          DEFAULT ('{}'),
    ddoddl         CHAR (38),
    revision       INTEGER       NOT NULL
                                 DEFAULT 0,
    revision_from  INTEGER       DEFAULT 0,
    revision_to    INTEGER       DEFAULT -1,
    ghost          BOOLEAN       DEFAULT 0,
    cm_modified_by CHAR (38)     NOT NULL,
    cm_revision    INTEGER       DEFAULT (0),
    cm_deleted     BOOLEAN       DEFAULT 0,
    cm_timestamp   DATETIME      DEFAULT (CURRENT_TIMESTAMP),
    repository     CHAR (38),
    CONSTRAINT Unq_dm_item_uuid UNIQUE (
        uuid,
        revision
    ),
    FOREIGN KEY (
        diagram
    )
    REFERENCES dm_diagram (uuid) ON DELETE CASCADE
);

INSERT INTO dm_item (
                        uuid,
                        diagram,
                        type,
                        ddoddl,
                        revision,
                        revision_from,
                        revision_to,
                        ghost,
                        cm_modified_by,
                        cm_deleted,
                        repository
                    )
                    SELECT uuid,
                           diagram,
                           type,
                           ddoddl,
                           revision,
                           revision_from,
                           revision_to,
                           ghost,
                           cm_modified_by,
                           cm_deleted,
                           repository
                      FROM sqlitestudio_temp_table;

DROP TABLE sqlitestudio_temp_table;

CREATE INDEX idx_dm_shape ON dm_item (
    diagram
);

CREATE INDEX idx_dm_shape_ddoddl ON dm_item (
    ddoddl
);

DROP TABLE dm_diagram_property;
DROP TABLE dm_item_property;

PRAGMA foreign_keys = 1;

DROP VIEW dm_items;

CREATE VIEW dm_items AS
    SELECT dm.solution AS ds_uuid,
           di.uuid AS di_uuid,
           dm.uuid AS dm_uuid,
           di.type AS di_type,
           di.properties AS di_properties,
           di.ddoddl AS di_ddoddl,
           di.ghost AS di_ghost,
           di.revision_from AS di_revision_from
      FROM dm_item AS di
           LEFT JOIN
           dm_diagram dm ON (dm.uuid = di.diagram);

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
	cm_deleted           boolean  DEFAULT 0   ,
	repository           char(38) NOT NULL    
 );

CREATE INDEX idx_dm_item ON dm_item_history ( uuid, cm_revision );

CREATE TRIGGER tg_dm_item_au
         AFTER UPDATE OF properties,
                         revision_to,
                         ghost
            ON dm_item
BEGIN
    UPDATE dm_diagram_item
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