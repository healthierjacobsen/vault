# reporting schema

This schema is used by the API to trigger summary jobs and access summary information


## Routines

* account_calculations - Scheduled to run nightly to summarize organization level data.
* org_program_status - Run by the API to populate the `reporting.org_program_status` table with the current status of an organizations progress for assessments in a given project.


## Tables

* org_program_status - Contains the current status of an organizations progress for assessments in a given project. Populated by the `reporting.org_program_status` routine.
