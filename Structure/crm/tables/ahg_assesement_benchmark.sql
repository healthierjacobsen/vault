/**
  This table stores the assessment benchmark data for organizations for the primary purpose of syncing to CRM
  The population of this table is completed as part of the reporting.account_calculations stored procedure
  The table is truncated for each run of the stored procedure and only contains entries for the reporting period (typically 24 hours)
  The ahg_account column keys to the live_data.organizations.crm_site_id column
  The ahg_assessment column keys to the live_data.sets.crm_id column
 */

DROP TABLE IF EXISTS crm.ahg_assesement_benchmark;

CREATE TABLE crm.ahg_assesement_benchmark
(
    ahg_account               varchar,
    ahg_assessment            varchar,
    ahg_assessmentbenchmarkid varchar,
    ahg_baselinedate          timestamp,
    ahg_name                  varchar,
    ahg_startdate             timestamp,
    ahg_updatedate            timestamp,
    createdby                 varchar,
    createdon                 timestamp,
    modifiedby                varchar,
    modifiedon                timestamp,
    ownerid                   varchar,
    owningbusinessunit        varchar,
    owningteam                varchar,
    owninguser                varchar,
    statecode                 varchar,
    statuscode                varchar,
    vault_id                  serial NOT NULL
        CONSTRAINT ahg_assesement_benchmark_pk
            PRIMARY KEY
);

ALTER TABLE crm.ahg_assesement_benchmark
    OWNER TO postgres;

COMMENT ON TABLE crm.ahg_assesement_benchmark IS 'This table stores the assessment benchmark data for organizations for the primary purpose of syncing to CRM';

GRANT SELECT,
    USAGE ON SEQUENCE crm.ahg_assesement_benchmark_vault_id_seq TO main;

CREATE INDEX ahg_assesement_benchmark_ahg_account_ahg_assessment_index
    ON crm.ahg_assesement_benchmark (ahg_account, ahg_assessment);

CREATE INDEX ahg_assesement_benchmark_ahg_account_ahg_startdate_ahg_updateda
    ON crm.ahg_assesement_benchmark (ahg_assessment, ahg_account, ahg_startdate, ahg_updatedate);

GRANT DELETE, INSERT, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON crm.ahg_assesement_benchmark TO main;

GRANT SELECT ON crm.ahg_assesement_benchmark TO sql_analyst;

GRANT SELECT ON crm.ahg_assesement_benchmark TO chartio;

