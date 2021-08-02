/**
  This table stores the online_enrollment_date for organizations for the purpose of syncing to CRM
  The population of this table is completed as part of the reporting.account_calculations stored procedure
  The table is truncated for each run of the stored procedure and only contains entries for the reporting period (typically 24 hours)
 */

DROP TABLE IF EXISTS crm.account_enrollment_date;

CREATE TABLE crm.account_enrollment_date
(
    p2orgid                integer   NOT NULL
        CONSTRAINT account_enrollment_date_pk
            PRIMARY KEY,
    online_enrollment_date timestamp NOT NULL
);

ALTER TABLE crm.account_enrollment_date
    OWNER TO main;

COMMENT ON TABLE crm.account_enrollment_date IS 'This table stores the online_enrollment_date for organizations for the purpose of syncing to CRM';

GRANT DELETE, INSERT, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON crm.account_enrollment_date TO sql_analyst;

GRANT SELECT ON crm.account_enrollment_date TO chartio;

