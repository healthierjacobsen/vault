/**
  This table stores the last_activity_hsp for organizations for the purpose of syncing to CRM
  The population of this table is completed as part of the reporting.account_calculations stored procedure
  The table is truncated for each run of the stored procedure and only contains entries for the reporting period (typically 24 hours)
 */

DROP TABLE IF EXISTS crm.account_last_activity;

CREATE TABLE crm.account_last_activity
(
    p2orgid           integer   NOT NULL
        CONSTRAINT account_last_activity_pk
            PRIMARY KEY,
    last_activity_hsp timestamp NOT NULL
);

ALTER TABLE crm.account_last_activity
    OWNER TO main;

COMMENT ON TABLE crm.account_last_activity IS 'This table stores the last_activity_hsp for organizations for the purpose of syncing to CRM';

GRANT DELETE, INSERT, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON crm.account_last_activity TO sql_analyst;

GRANT SELECT ON crm.account_last_activity TO chartio;

