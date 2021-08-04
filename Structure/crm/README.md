# CRM schema

This schema is mainly used as a location for data to flow back and forth with CRM.

## Data Syncing

* All data in this schema that is syncing with CRM is performed as part of a Scribe job.

## Source of truth

### CRM
- `ahg_account_ahg_grant` - This table stores the relationship of an organization to a grant from CRM
- `ahg_grant` - This table stores the grant records from CRM
- `engagement` - This table stores the engagement records from CRM

**Note:** These tables are only modified as inserts or updates. Any deletes will need to be run through [Steve (Stan the man)](mailto:steve.bambakidis@healthiergeneration.org)

### Vault
- `account_action_plan_start` - This table stores the action plan start date for organizations for the purpose of syncing to CRM
- `account_action_plan_update` - This table stores the action plan update date for organizations for the purpose of syncing to CRM
- `account_calculations` - This table stores the web_team_config and award eligibility for organizations for the purpose of syncing to CRM
- `account_enrollment_date` - This table stores the online_enrollment_date for organizations for the purpose of syncing to CRM
- `account_last_activity` - This table stores the last_activity_hsp for organizations for the purpose of syncing to CRM
- `ahg_assessment_benchmark` - This table stores the assessment benchmark data for organizations for the primary purpose of syncing to CRM

**Note:** These are all populated via the reporting.account_calculations routine 
