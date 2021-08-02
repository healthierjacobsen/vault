-- School RISE Baseline Responses - Julie's version, don't use:
SELECT sp_baseline_responses(3000, 5, 100, '2021-05-31');
SELECT l.*
FROM baseline_responses_ct l;

-- District RISE Baseline Responses:
SELECT sp_baseline_responses(3000, 6, 200, '2021-05-31');
SELECT l.*
FROM baseline_responses_ct l;

-- schools - Wayne's version
SELECT sp_baseline_responses(3000, 5, 100, '2021-05-31');
WITH oe AS (
    SELECT o.id,
           o.pid                                                              AS school_pid,
           o.name                                                             AS school_name,
           o.city,
           UPPER(o.state_id)                                                  AS state,
           o.postcode,
           o.parent                                                           AS district_name,
           o.parent_pid                                                       AS district_pid,
           CASE WHEN e.ahg_supporttype = '124680000' THEN 'Yes' ELSE 'No' END AS "rise_onsite"
    FROM live_data.v_organizations o
             LEFT JOIN crm.engagement e ON e.ahg_account::varchar = o.crm_site_id AND e.ahg_program = '124680002' AND
                                           e.statecode::int = 0
    WHERE o.deleted_at IS NULL
      AND o.is_demo = FALSE
)
SELECT oe.id,
       oe.school_pid,
       oe.school_name,
       oe.city,
       oe.state,
       oe.postcode,
       oe.district_name,
       oe.district_pid,
       oe."rise_onsite",
       CASE WHEN b.baseline_all_date IS NULL THEN 'No' ELSE 'Yes' END AS "baseline_all",
       b.baseline_all_date                                            AS baseline_date,
       l.*,
       m.* --, o.*
FROM baseline_responses_ct l
         JOIN temp_baseline_responses_mod_baselines_ct m ON m.id = l.organization_id
         JOIN public.sp_org_baselined_all(5, 'temp_baseline_responses_mod_baselines_ct') b ON b.org_id = m.id
         JOIN oe ON oe.id = l.organization_id
ORDER BY oe.state, oe.district_name, oe.school_name ASC;

-- districts
SELECT sp_baseline_responses(3000, 6, 200, '2021-05-31');
WITH oe AS (
    SELECT o.id,
           o.pid                                                              AS district_pid,
           o.name                                                             AS district_name,
           o.city,
           UPPER(o.state_id)                                                  AS state,
           o.postcode,
           CASE WHEN e.ahg_supporttype = '124680000' THEN 'Yes' ELSE 'No' END AS "rise_onsite"
    FROM live_data.v_organizations o
             LEFT JOIN crm.engagement e ON e.ahg_account::varchar = o.crm_site_id AND e.ahg_program = '124680002' AND
                                           e.statecode::int = 0
    WHERE o.deleted_at IS NULL
      AND o.is_demo = FALSE
)
SELECT oe.id,
       oe.district_pid,
       oe.district_name,
       oe.city,
       oe.state,
       oe.postcode,
       oe."rise_onsite",
       CASE WHEN b.baseline_all_date IS NULL THEN 'No' ELSE 'Yes' END AS "baseline_all",
       b.baseline_all_date                                            AS baseline_date,
       l.*,
       m.* --, o.*
FROM baseline_responses_ct l
         JOIN temp_baseline_responses_mod_baselines_ct m ON m.id = l.organization_id
         JOIN public.sp_org_baselined_all(6, 'temp_baseline_responses_mod_baselines_ct') b ON b.org_id = m.id
         JOIN oe ON oe.id = l.organization_id
ORDER BY oe.state, oe.district_name ASC;