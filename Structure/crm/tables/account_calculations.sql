/**
  This table stores the web_team_config and award eligibility for organizations for the purpose of syncing to CRM
  The population of this table is completed as part of the reporting.account_calculations stored procedure
  The table is truncated for each run of the stored procedure and only contains entries for the reporting period (typically 24 hours)
 */

DROP TABLE IF EXISTS crm.account_calculations;

CREATE TABLE crm.account_calculations
(
    p2orgid           integer NOT NULL
        CONSTRAINT account_calculations_pk
            PRIMARY KEY,
    web_team_config   integer,
    award_eligibility varchar
);

ALTER TABLE crm.account_calculations
    OWNER TO main;

COMMENT ON TABLE crm.account_calculations IS 'This table stores the web_team_config and award eligibility for organizations for the purpose of syncing to CRM';

GRANT DELETE, INSERT, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON crm.account_calculations TO sql_analyst;

GRANT SELECT ON crm.account_calculations TO chartio;

