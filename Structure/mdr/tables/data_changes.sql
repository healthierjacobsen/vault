CREATE TABLE mdr.data_changes
(
    id               serial
        CONSTRAINT data_changes_pk
            PRIMARY KEY,
    organization_pid integer                 NOT NULL,
    mdr_field        varchar,
    crm_field        varchar,
    new_value        varchar                 NOT NULL,
    created_at       timestamp DEFAULT NOW() NOT NULL,
    verified_at      timestamp,
    hg_status        varchar                 NOT NULL
);

ALTER TABLE mdr.data_changes
    OWNER TO sql_analyst;

GRANT SELECT ON mdr.data_changes TO chartio;

