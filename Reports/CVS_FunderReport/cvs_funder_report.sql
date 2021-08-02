--assessment_id,program_id
--9,6000
--17,6000
--16,6000

--SELECT * FROM crm.ahg_grant WHERE ahg_name = 'CVS';

--SELECT * FROM crm.ahg_program WHERE p2_program_id = 6000;

SELECT COUNT(1)                                                                          AS recruited,
       COUNT(1) FILTER ( WHERE e.ahg_supporttype = '124680000' )                         AS onsite,
       COUNT(1) FILTER ( WHERE e.ahg_supporttype = '124680001' )                         AS virtual,
       COUNT(1) FILTER ( WHERE od.is_title_1 )                                           AS recruited_title_1,
       COUNT(1) FILTER ( WHERE e.ahg_supporttype = '124680000' AND od.is_title_1 )       AS onsite_title_1,
       COUNT(1) FILTER ( WHERE e.ahg_supporttype = '124680001' AND od.is_title_1 )       AS virtual_title_1,
       SUM(od.school_year_enrollment)                                                    AS district_students,
       SUM(od.school_year_enrollment) FILTER ( WHERE od.is_title_1 )                     AS district_students_title_1,
       ROUND(SUM((od.school_year_enrollment::int * (od.minority_percent::float / 100)))) AS bipoc_students
FROM crm.ahg_account_ahg_grant aaag
         JOIN crm.engagement e ON e.ahg_account = aaag.accountid
         JOIN crm.ahg_grant ag ON ag.ahg_grantid = aaag.ahg_grantid
         JOIN crm.ahg_program ap ON ap.ahg_program = e.ahg_program
         JOIN live_data.organizations o ON o.crm_site_id = aaag.accountid::varchar
         JOIN public.organization_demographics od ON o.id = od.organization_id
WHERE ap.p2_program_id = 6000
  AND ag.ahg_name = 'CVS'
  AND o.deleted_at IS NULL
  AND o.is_demo IS FALSE
  AND e.statecode = '0'
  AND e.ahg_servicestartdate <= '2021-04-30'
;


SELECT COUNT(school.id)                                                           AS schools_in_recruited,
       COUNT(school.id) FILTER ( WHERE od.frl_percent IS NOT NULL )               AS schools_w_frl_data,
       COUNT(school.id) FILTER ( WHERE od.is_title_1 )                            AS schools_title_1,
       COUNT(school.id) FILTER ( WHERE od.minority_percent IS NOT NULL )          AS schools_w_minority_data,
       COUNT(school.id) FILTER ( WHERE od.is_majority_minority )                  AS schools_majority_minority,
       SUM(od.school_year_enrollment)                                             AS school_students,
       SUM(od.school_year_enrollment) FILTER ( WHERE od.frl_percent IS NOT NULL ) AS school_students_w_frl_data,
       SUM(od.school_year_enrollment) FILTER ( WHERE od.is_title_1 )              AS school_students_title_1
FROM crm.ahg_account_ahg_grant aaag
         JOIN crm.engagement e ON e.ahg_account = aaag.accountid
         JOIN crm.ahg_grant ag ON ag.ahg_grantid = aaag.ahg_grantid
         JOIN crm.ahg_program ap ON ap.ahg_program = e.ahg_program
         JOIN live_data.organizations o ON o.crm_site_id = aaag.accountid::varchar
         JOIN live_data.organizations school ON school.parent_id = o.id
         JOIN public.organization_demographics od ON school.id = od.organization_id
WHERE ap.p2_program_id = 6000
  AND ag.ahg_name = 'CVS'
  AND o.deleted_at IS NULL
  AND o.is_demo IS FALSE
  AND school.is_demo = FALSE
  AND school.deleted_at IS NULL
  AND school.organization_type_id = 100
  AND e.statecode = '0'
  AND e.ahg_servicestartdate <= '2021-04-30'
;


WITH r AS (
    SELECT o.id
    FROM live_data.criterion_instances ci
             JOIN live_data.organization_criteria oc ON ci.criterion_id = oc.criterion_id
             JOIN live_data.organizations o ON oc.organization_id = o.id
             JOIN live_data.sets s ON ci.set_id = s.id
             JOIN live_data.responses r ON ci.criterion_id = r.criterion_id
        AND r.organization_id = o.id
        AND r.first
        AND r.created_at > (SELECT created_at FROM live_data.sets WHERE id = 9)
    WHERE s.program_id = 6000
      AND ci.deleted_at IS NULL
      AND o.is_demo = FALSE
      AND o.deleted_at IS NULL
      AND r.created_at <= '2021-04-30'
    GROUP BY o.id
),
     p AS (
         SELECT o.id
         FROM live_data.criterion_instances ci
                  JOIN live_data.sets s ON ci.set_id = s.id
                  JOIN live_data.organization_criteria oc ON ci.criterion_id = oc.criterion_id
                  JOIN live_data.organizations o ON oc.organization_id = o.id
                  JOIN live_data.plans p ON p.organization_id = o.id
                  JOIN live_data.plan_items pi ON pi.criterion_id = oc.criterion_id AND pi.plan_id = p.id
         WHERE s.program_id = 6000
           AND ci.deleted_at IS NULL
           AND o.is_demo = FALSE
           AND o.deleted_at IS NULL
           AND p.deleted_at IS NULL
           AND pi.deleted_at IS NULL
           AND pi.created_at <= '2021-04-30'
         GROUP BY o.id
     )

SELECT COUNT(o.id) FILTER ( WHERE (r.id IS NOT NULL OR p.id IS NOT NULL) )                             AS worked_on_assessment_or_action_plan,
       COUNT(o.id)
       FILTER ( WHERE (r.id IS NOT NULL OR p.id IS NOT NULL) AND od.is_title_1 )                       AS title_1_worked_on_assessment_or_action_plan,
       COUNT(o.id) FILTER ( WHERE r.id IS NOT NULL AND od.is_title_1 )                                 AS title_1_worked_on_assessment,
       COUNT(o.id) FILTER ( WHERE p.id IS NOT NULL AND od.is_title_1 )                                 AS title_1_worked_on_action_plan,
       COUNT(o.id)
       FILTER ( WHERE (r.id IS NOT NULL OR p.id IS NOT NULL) AND od.is_majority_minority )             AS major_min_worked_on_assessment_or_action_plan,
       COUNT(o.id)
       FILTER ( WHERE r.id IS NOT NULL AND od.is_majority_minority )                                   AS major_min_worked_on_assessment,
       COUNT(o.id)
       FILTER ( WHERE p.id IS NOT NULL AND od.is_majority_minority )                                   AS major_min_worked_on_action_plan

FROM crm.ahg_account_ahg_grant aaag
         JOIN crm.engagement e ON e.ahg_account = aaag.accountid
         JOIN crm.ahg_grant ag ON ag.ahg_grantid = aaag.ahg_grantid
         JOIN crm.ahg_program ap ON ap.ahg_program = e.ahg_program
         JOIN live_data.organizations o ON o.crm_site_id = aaag.accountid::varchar
         JOIN public.organization_demographics od ON o.id = od.organization_id
         LEFT JOIN r ON r.id = o.id
         LEFT JOIN p ON p.id = o.id
WHERE ap.p2_program_id = 6000
  AND ag.ahg_name = 'CVS'
  AND o.deleted_at IS NULL
  AND o.is_demo IS FALSE
  AND e.statecode = '0'
  AND e.ahg_servicestartdate <= '2021-04-30'
;



WITH c AS (
    SELECT o.id,
           ci.module_id,
           COUNT(oc.criterion_id) AS criteria,
           COUNT(r.criterion_id)  AS responses
    FROM live_data.criterion_instances ci
             JOIN live_data.organization_criteria oc ON ci.criterion_id = oc.criterion_id
             JOIN live_data.organizations o ON oc.organization_id = o.id
             JOIN live_data.sets s ON ci.set_id = s.id
             LEFT JOIN live_data.responses r ON ci.criterion_id = r.criterion_id
        AND r.organization_id = o.id
        AND r.first
        AND r.created_at BETWEEN (SELECT created_at FROM live_data.sets WHERE id = 9) AND '2021-04-30'

    WHERE s.program_id = 6000
      AND o.is_demo = FALSE
      AND o.deleted_at IS NULL
    GROUP BY o.id, ci.module_id
)
SELECT COUNT(DISTINCT o.id)                                                                                           AS completed_a_module,
       COUNT(DISTINCT o.id)
       FILTER ( WHERE aab.ahg_baselinedate IS NOT NULL AND aab.ahg_baselinedate <= '2021-04-30')                      AS completed_assessment,
       COUNT(DISTINCT o.id) FILTER ( WHERE od.is_title_1 )                                                            AS title_1_completed_a_module,
       COUNT(DISTINCT o.id) FILTER ( WHERE od.is_title_1 AND aab.ahg_baselinedate IS NOT NULL AND
                                           aab.ahg_baselinedate <=
                                           '2021-04-30' )                                                             AS title_1_completed_assessment,
       COUNT(DISTINCT o.id) FILTER ( WHERE od.is_majority_minority )                                                  AS major_min_completed_a_module,
       COUNT(DISTINCT o.id) FILTER ( WHERE od.is_majority_minority AND aab.ahg_baselinedate IS NOT NULL AND
                                           aab.ahg_baselinedate <= '2021-04-30' )
                                                                                                                      AS major_min_completed_assessment
FROM crm.ahg_account_ahg_grant aaag
         JOIN crm.engagement e ON e.ahg_account = aaag.accountid
         JOIN crm.ahg_grant ag ON ag.ahg_grantid = aaag.ahg_grantid
         JOIN crm.ahg_program ap ON ap.ahg_program = e.ahg_program
         JOIN live_data.organizations o ON o.crm_site_id = aaag.accountid::varchar
         JOIN public.organization_demographics od ON o.id = od.organization_id
         JOIN crm.ahg_assesement_benchmark aab
              ON aab.ahg_account = o.crm_site_id AND aab.ahg_assessment = (SELECT crm_id
                                                                           FROM live_data.sets
                                                                           WHERE program_id = 6000
                                                                             AND organization_type_id = 200)
         JOIN c ON c.id = o.id
WHERE c.responses = c.criteria
  AND ap.p2_program_id = 6000
  AND ag.ahg_name = 'CVS'
  AND o.deleted_at IS NULL
  AND o.is_demo IS FALSE
  AND e.statecode = '0'
  AND e.ahg_servicestartdate <= '2021-04-30'
;


WITH i AS (SELECT o.id,
                  COUNT(r.criterion_id) AS improvements
           FROM public.baseline_responses br
                    JOIN live_data.responses r
                         ON br.criterion_id = r.criterion_id AND br.organization_id = r.organization_id
                    JOIN live_data.response_values brv ON br.response_value_id = brv.id
                    JOIN live_data.response_values rv ON r.response_value_id = rv.id
                    JOIN live_data.criterion_instances ci ON ci.criterion_id = r.criterion_id
                    JOIN live_data.sets s ON s.id = ci.set_id
                    JOIN live_data.organizations o ON o.id = r.organization_id

           WHERE r.latest
             AND s.program_id = 6000
             AND s.organization_type_id = 200
             AND o.deleted_at IS NULL
             AND o.is_demo IS FALSE
             AND (rv.alignment > brv.alignment)
             AND r.created_at <= '2021-04-30'
             AND br.created_at <= '2021-04-30'
           GROUP BY o.id
),
     e AS (
         SELECT o.id, e.ahg_supporttype
         FROM live_data.organizations o
                  JOIN crm.ahg_account_ahg_grant aaag ON o.crm_site_id = aaag.accountid::varchar
                  JOIN crm.engagement e ON e.ahg_account = aaag.accountid
                  JOIN crm.ahg_grant ag ON ag.ahg_grantid = aaag.ahg_grantid
                  JOIN crm.ahg_program ap ON ap.ahg_program = e.ahg_program
         WHERE o.deleted_at IS NULL
           AND o.is_demo IS FALSE
           AND ap.p2_program_id = 6000
           AND ag.ahg_name = 'CVS'
           AND e.statecode = '0'
           AND e.ahg_servicestartdate <= '2021-04-30'
     )
SELECT COUNT(i.id) FILTER ( WHERE i.improvements >= 2 )                                    AS "districts_2+_improvements",
       COUNT(i.id) FILTER ( WHERE i.improvements >= 2 AND e.id IS NULL)                    AS "districts_2+_improvements_non_cvs",
       COUNT(i.id) FILTER ( WHERE i.improvements >= 2 AND e.id IS NOT NULL)                AS "districts_2+_improvements_cvs",
       COUNT(i.id)
       FILTER ( WHERE i.improvements >= 2 AND e.ahg_supporttype = '124680000')             AS "districts_2+_improvements_cvs_onsite",
       COUNT(i.id)
       FILTER ( WHERE i.improvements >= 2 AND e.ahg_supporttype = '124680001')             AS "districts_2+_improvements_cvs_virtual",
       COUNT(i.id) FILTER ( WHERE i.improvements >= 1 )                                    AS "districts_1+_improvements",
       COUNT(i.id) FILTER ( WHERE i.improvements >= 1 AND e.id IS NULL)                    AS "districts_1+_improvements_non_cvs",
       COUNT(i.id) FILTER ( WHERE i.improvements >= 1 AND e.id IS NOT NULL)                AS "districts_1+_improvements_cvs",
       COUNT(i.id)
       FILTER ( WHERE i.improvements >= 1 AND e.ahg_supporttype = '124680000')             AS "districts_1+_improvements_cvs_onsite",
       COUNT(i.id)
       FILTER ( WHERE i.improvements >= 1 AND e.ahg_supporttype = '124680001')             AS "districts_1+_improvements_cvs_virtual"
FROM i
         LEFT JOIN e ON e.id = i.id
;


--num of improvements / num of districts
WITH i AS (SELECT o.id,
                  COUNT(r.criterion_id) AS improvements
           FROM public.baseline_responses br
                    JOIN live_data.responses r
                         ON br.criterion_id = r.criterion_id AND br.organization_id = r.organization_id
                    JOIN live_data.response_values brv ON br.response_value_id = brv.id
                    JOIN live_data.response_values rv ON r.response_value_id = rv.id
                    JOIN live_data.criterion_instances ci ON ci.criterion_id = r.criterion_id
                    JOIN live_data.sets s ON s.id = ci.set_id
                    JOIN live_data.organizations o ON o.id = r.organization_id

           WHERE r.latest
             AND s.program_id = 6000
             AND s.organization_type_id = 200
             AND o.deleted_at IS NULL
             AND o.is_demo IS FALSE
             AND (rv.alignment > brv.alignment)
             AND r.created_at <= '2021-04-30'
             AND br.created_at <= '2021-04-30'
           GROUP BY o.id
),
     r AS (
         SELECT o.id
         FROM live_data.criterion_instances ci
                  JOIN live_data.organization_criteria oc ON ci.criterion_id = oc.criterion_id
                  JOIN live_data.organizations o ON oc.organization_id = o.id
                  JOIN live_data.sets s ON ci.set_id = s.id
                  JOIN live_data.responses r ON ci.criterion_id = r.criterion_id
             AND r.organization_id = o.id
             AND r.first
             AND r.created_at BETWEEN (SELECT created_at FROM live_data.sets WHERE id = 9) AND '2021-04-30'
         WHERE s.program_id = 6000
           AND ci.deleted_at IS NULL
           AND o.is_demo = FALSE
           AND o.deleted_at IS NULL
         GROUP BY o.id
     ),
     e AS (
         SELECT o.id, e.ahg_supporttype
         FROM live_data.organizations o
                  JOIN crm.ahg_account_ahg_grant aaag ON o.crm_site_id = aaag.accountid::varchar
                  JOIN crm.engagement e ON e.ahg_account = aaag.accountid
                  JOIN crm.ahg_grant ag ON ag.ahg_grantid = aaag.ahg_grantid
                  JOIN crm.ahg_program ap ON ap.ahg_program = e.ahg_program
         WHERE o.deleted_at IS NULL
           AND o.is_demo IS FALSE
           AND ap.p2_program_id = 6000
           AND ag.ahg_name = 'CVS'
           AND e.statecode = '0'
           AND e.ahg_servicestartdate <= '2021-04-30'
     )

SELECT SUM(i.improvements) / COUNT(r.id)                                                                   AS "avg_improvements_per_district",
       SUM(i.improvements) FILTER ( WHERE e.id IS NULL) /
       COUNT(r.id) FILTER ( WHERE e.id IS NULL)                                                            AS "avg_improvements_per_district_non_cvs",
       SUM(i.improvements) FILTER ( WHERE e.id IS NOT NULL) /
       COUNT(r.id) FILTER ( WHERE e.id IS NOT NULL)                                                        AS "avg_improvements_per_district_cvs",
       SUM(i.improvements) FILTER ( WHERE e.ahg_supporttype = '124680000') /
       COUNT(r.id) FILTER ( WHERE e.ahg_supporttype = '124680000')
                                                                                                           AS "avg_improvements_per_district_cvs_onsite",
       SUM(i.improvements) FILTER ( WHERE e.ahg_supporttype = '124680001') /
       COUNT(r.id) FILTER ( WHERE e.ahg_supporttype = '124680001')
                                                                                                           AS "avg_improvements_per_district_cvs_virtual"
FROM r
         LEFT JOIN i ON i.id = r.id
         LEFT JOIN e ON e.id = r.id
;