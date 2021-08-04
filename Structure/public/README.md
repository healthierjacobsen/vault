# public schema

This schema is an open space for everyone to use.


## Materialized Views

- `baseline_responses` - A view of all baseline responses accounting for the 48 hour correction window. The last response, after the initial, made within 48 hours of the first will be designated as the baseline response.

## Routines

- `cf_summary_data` - [Documented](../../Reports/CF_Metrics/README.md)


- `ever_enrolled_close_accts_excluded` - [Documented](../../Reports/CF_Metrics/README.md)


- `org_last_activity` - Used to retrieve the timestamp of the most recent activity by a team member


- `org_module_baseline` - Used to check if an org has baselined a module as well as the baseline date


- `sp_assessment_baseline_responses` - Same as `sp_baseline_responses` 
  - Used by `public.sp_calculate_benchmarks`


- `sp_baseline_responses` - Builds temp tables (baseline_responses_ct & temp_baseline_responses_mod_baselines_ct) with the current baseline info for an assessment


- `sp_baseline_responses_kp` - Used for KP-HEAL. No longer in use. Has special mapping of response dates to reporting period start.


- `sp_bcbs` - [Documented](../../Reports/BCBS_SC_WISE/README.md)


- `sp_calculate_benchmarks` - Populates the `crm.ahg_assessment_benchmark` table with the current status for an assessment.
  - Used by `reporting.account_calculations`


- `sp_cdc_nutrition` - [Documented](../../Reports/CDC/README.md)


- `sp_cdc_ost` - [Documented](../../Reports/CDC/README.md)


- `sp_latest_responses` - Builds temp tables (latest_responses_ct & temp_latest_responses_mod_baselines_ct) with the current baseline info for an assessment


- `sp_latest_responses_kp` - Used for KP-HEAL. No longer in use. Has special mapping of response dates to reporting period start.


- `sp_mod_baseline_ct` - Creates a temp table with the module baselines (boolean indicating if they have baselined a module)  as columns from an input table
  - Used by `public.sp_module_baseline`


- `sp_mod_baseline_date_ct` - Creates a temp table with the module baseline dates as columns from an input table 
  - Used by `public.sp_module_baseline`


- `sp_module_baseline` - Creates a temp table with the combination of both `sp_mod_baseline_ct` and `sp_mod_baseline_date_ct` data.
  - Used by `public.sp_assessment_baseline_responses, public.sp_baseline_responses, public.sp_baseline_responses_kp, public.sp_latest_responses, public.sp_latest_responses_kp`


- `sp_org_assessment_baseline` - No longer in use.


- `sp_org_assessment_benchmark_dates` - Used to retrieve the benchmark dates (start or update) from the input table.
  - Used by `public.sp_calculate_benchmarks`


- `sp_org_assessment_start` - No longer in use.


- `sp_org_baselined_all` - Used to retrieve the baseline date that all modules have been baselined (date last module was baselined).
  - Used by `public.sp_calculate_benchmarks, public.sp_qsha_summary` and [KP-RISE](../../Reports/KP-RISE/kp_rise_baseline_responses.sql)


- `sp_qsha_summary` - [Documented](../../Reports/KP-QSHA/README.md)


- `sp_responses_date_ct` - Creates a temp table with the criterion response dates as columns from an input table
  - Used by `public.sp_assessment_baseline_responses, public.sp_baseline_responses, public.sp_baseline_responses_kp, public.sp_latest_responses, public.sp_latest_responses_kp`


- `sp_responses_value_ct` - Creates a temp table with the criterion response values as columns from an input table
  - Used by `public.sp_assessment_baseline_responses, public.sp_baseline_responses, public.sp_baseline_responses_kp, public.sp_latest_responses, public.sp_latest_responses_kp`




## Tables

- `organization_demographics` - Contains demographics information for a organizations from CRM. Populated by the API.
- `organization_intermediary` - Used to provide a lookup of an organizations intermediary status. Populated by the API.
- `reporting_modules` - This is a mapping of `criterion_instances`.`handle` to grouping used for some reports (BCBS).

** The tables listed above are the only ones documented as they are permanent **