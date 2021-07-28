# CRM schema

This schema is mainly used as a location for data to flow back and forth with CRM.

## Data Syncing

* All data in this schema that is syncing with CRM is performed as part of a Scribe job.

## Source of truth

### CRM
* ahg_account_ahg_grant
* ahg_grant
* engagement

**Note:** These tables are only modified as inserts or updates. Any deletes will need to be run through [Steve (Stan the man)](mailto:steve.bambakidis@healthiergeneration.org)

### Vault
* account_action_plan_start
* account_action_plan_update
* account_calculations
* account_enrollment_date
* account_last_activity
* ahg_assessment_benchmark

**Note:** These are all populated via the reporting.account_calculations routine 
