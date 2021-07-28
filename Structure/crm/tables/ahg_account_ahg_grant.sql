/**
  This table stores the relationship of an organization to a grant from CRM
  The population of this table is completed as part of the nightly Scribe sync
  The accountid column keys to the live_data.organizations.crm_site_id column
  The ahg_grantid column keys to the crm.ahg_grant.ahg_grantid column
 */

DROP TABLE IF EXISTS crm.ahg_account_ahg_grant;

CREATE TABLE crm.ahg_account_ahg_grant
(
    accountid               uuid,
    ahg_account_ahg_grantid uuid NOT NULL
        CONSTRAINT ahg_account_ahg_grant_two_pkey
            PRIMARY KEY,
    ahg_grantid             uuid
);

ALTER TABLE crm.ahg_account_ahg_grant
    OWNER TO postgres;

CREATE INDEX ahg_account_ahg_grant_accountid_ahg_grantid_index
    ON crm.ahg_account_ahg_grant (accountid, ahg_grantid);

GRANT DELETE, INSERT, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON crm.ahg_account_ahg_grant TO main;

GRANT SELECT ON crm.ahg_account_ahg_grant TO sql_analyst;

GRANT SELECT ON crm.ahg_account_ahg_grant TO chartio;

