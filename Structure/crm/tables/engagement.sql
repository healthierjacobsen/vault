/**
  This table stores the engagement records from CRM
  The population of this table is completed as part of the nightly Scribe job
  The ahg_account column keys to the live_data.organizations.crm_site_id column
  The ahg_program column keys to the crm.ahg_program.ahg_program column
  The ahg_supporttype column keys to the crm.ahg_support_type.id column
  The statecode column values are mapped as (0 = active, 1 = inactive)
 */

DROP TABLE IF EXISTS crm.engagement;

CREATE TABLE crm.engagement
(
    ahg_engagementid            uuid NOT NULL
        CONSTRAINT "EngagementIDPK"
            PRIMARY KEY,
    ahg_account                 uuid,
    ahg_accountname             varchar,
    ahg_accountyominame         varchar,
    ahg_expirationdate          timestamp,
    ahgmoureceiveddate          timestamp,
    ahg_name                    varchar,
    ahg_program                 varchar,
    ahg_program_displayname     varchar,
    ahg_serviceenddate          timestamp,
    ahg_servicestartdate        timestamp,
    ahg_supporttype             varchar,
    ahg_supporttype_displayname varchar,
    ahg_type                    varchar,
    ahg_type_displayname        varchar,
    createdby                   varchar,
    createdbyname               varchar,
    createdbyyominame           varchar,
    createdon                   timestamp,
    createdonbehalfby           varchar,
    createdonbehalfbyname       varchar,
    createdonbehalfbyyominame   varchar,
    importsequencenumber        varchar,
    modifiedby                  uuid,
    modifiedbyname              varchar,
    modifiedbyyominame          varchar,
    modifiedon                  timestamp,
    statecode                   varchar,
    statuscode                  varchar
);

ALTER TABLE crm.engagement
    OWNER TO postgres;

CREATE INDEX engagement_ahg_program_ahg_serviceenddate_statuscode_index
    ON crm.engagement (ahg_program, ahg_serviceenddate, statuscode);

CREATE INDEX engagement_ahg_account_ahg_program_index
    ON crm.engagement (ahg_account, ahg_program);

GRANT DELETE, INSERT, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON crm.engagement TO main;

GRANT DELETE, INSERT, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON crm.engagement TO sql_analyst;

GRANT SELECT ON crm.engagement TO chartio;

