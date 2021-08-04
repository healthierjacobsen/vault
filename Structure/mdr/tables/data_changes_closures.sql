
DROP TABLE IF EXISTS mdr.data_changes_closures;

CREATE TABLE mdr.data_changes_closures
(
    id               serial
        CONSTRAINT data_changes_closures_pk
            PRIMARY KEY,
    organization_pid integer                 NOT NULL,
    created_at       timestamp DEFAULT NOW() NOT NULL,
    verified_at      timestamp,
    hg_status        varchar                 NOT NULL
);

ALTER TABLE mdr.data_changes_closures
    OWNER TO sql_analyst;

GRANT SELECT ON mdr.data_changes_closures TO chartio;

