/**
  This table stores the definitions of the CRM support types
  The population of this table is completely manual
 */

DROP TABLE IF EXISTS crm.ahg_support_type;

CREATE TABLE crm.ahg_support_type
(
    id   integer NOT NULL
        CONSTRAINT ahg_support_type_pk
            PRIMARY KEY,
    name varchar NOT NULL
);

ALTER TABLE crm.ahg_support_type
    OWNER TO main;

GRANT DELETE, INSERT, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON crm.ahg_support_type TO sql_analyst;

GRANT SELECT ON crm.ahg_support_type TO chartio;

