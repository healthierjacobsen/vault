/**
  This table stores the grant records from CRM
  The population of this table is completed as part of the nightly Scribe sync
  The statecode column values are mapped as (0 = active, 1 or null = inactive)
 */

DROP TABLE IF EXISTS crm.ahg_grant;

CREATE TABLE crm.ahg_grant
(
    ahg_name        varchar,
    ahg_grantid     uuid NOT NULL
        CONSTRAINT ahg_grant_two_pkey
            PRIMARY KEY,
    ahg_fundedgrant boolean,
    statecode       varchar
);

ALTER TABLE crm.ahg_grant
    OWNER TO postgres;

COMMENT ON TABLE crm.ahg_grant IS 'This table stores the grant records from CRM';

GRANT DELETE, INSERT, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON crm.ahg_grant TO main;

GRANT SELECT ON crm.ahg_grant TO sql_analyst;

GRANT SELECT ON crm.ahg_grant TO chartio;

