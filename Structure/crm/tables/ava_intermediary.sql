/**
  This table stores the definitions of the intermediary status's
  The population of this table is completely manual
 */

DROP TABLE IF EXISTS crm.ava_intermediary;

CREATE TABLE crm.ava_intermediary
(
    id   integer NOT NULL
        CONSTRAINT ava_intermediary_pk
            PRIMARY KEY,
    name varchar NOT NULL
);

ALTER TABLE crm.ava_intermediary
    OWNER TO main;

COMMENT ON TABLE crm.ava_intermediary IS 'This table stores the definitions of the intermediary status';

GRANT DELETE, INSERT, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON crm.ava_intermediary TO sql_analyst;

GRANT SELECT ON crm.ava_intermediary TO chartio;

