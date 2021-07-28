/**
  This table stores the action plan start date for organizations for the purpose of syncing to CRM
  The population of this table is completed as part of the reporting.account_calculations stored procedure
  The table is truncated for each run of the stored procedure and only contains entries for the reporting period (typically 24 hours)
 */

DROP TABLE IF EXISTS crm.account_action_plan_start;

CREATE TABLE crm.account_action_plan_start
(
    p2orgid           integer   NOT NULL
        CONSTRAINT account_action_plan_start_pk
            PRIMARY KEY,
    action_plan_start timestamp NOT NULL
);

ALTER TABLE crm.account_action_plan_start
    OWNER TO main;

GRANT DELETE, INSERT, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON crm.account_action_plan_start TO sql_analyst;

GRANT SELECT ON crm.account_action_plan_start TO chartio;

