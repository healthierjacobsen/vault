/**
  Query for the 2020 Impact Report. Results are total number of active accounts, active accounts with FRL % data,
  active accounts that are Title I, listed by account type (district, school, site)

  runtime ~1.5 min
 */

SELECT ot.name, COUNT(y.id) AS active, SUM(y.has_frl) AS has_frl, SUM(y.title1) AS is_title1
FROM (
         WITH l AS ( -- resources
             SELECT ou.organization_id
             FROM live_data.resource_access_logs ral
                      JOIN live_data.organization_user ou ON ou.user_id = ral.user_id
             WHERE ral.logged_at BETWEEN '2018-10-01' AND '2020-09-30'
               AND ral.user_id IS NOT NULL
               AND ou.organization_role_id IN (100, 200)
             GROUP BY ou.organization_id
         ),
              r AS ( -- assessment
                  SELECT r.organization_id
                  FROM live_data.responses r
                  WHERE r.created_at BETWEEN '2018-10-01' AND '2020-09-30'
                    AND r.user_id IS NOT NULL
                  GROUP BY r.organization_id
              ),
              p AS ( -- action plan
                  SELECT organization_id
                  FROM (
                           SELECT p.organization_id
                           FROM live_data.plan_items pi
                                    JOIN live_data.plans p ON pi.plan_id = p.id
                           WHERE (pi.created_at BETWEEN '2018-10-01' AND '2020-09-30' OR
                                  pi.updated_at BETWEEN '2018-10-01' AND '2020-09-30')
                             AND pi.created_by IS NOT NULL
                           UNION ALL
                           SELECT p.organization_id
                           FROM live_data.plan_items pi
                                    JOIN live_data.plans p ON pi.plan_id = p.id
                           WHERE pi.date_completed BETWEEN '2018-10-01' AND '2020-09-30'
                             AND pi.completed_by IS NOT NULL
                       ) AS pi
                  GROUP BY organization_id
              ),
              x AS ( -- orgs with guest or team members (non-staff)
                  SELECT o.id, o.organization_type_id
                  FROM live_data.organization_user ou
                           JOIN live_data.organizations o
                                ON o.id = ou.organization_id
                           JOIN live_data.users u ON u.id = ou.user_id
                  WHERE ou.organization_role_id IN (100, 200)
                    AND o.deleted_at IS NULL
                    AND o.is_demo = FALSE
                    AND o.organization_type_id IN (100, 200, 300)
                    AND u.email NOT LIKE '%@healthiergeneration.org%'
                  GROUP BY o.id, o.organization_type_id
              )

         SELECT x.id,
                CASE WHEN od.frl_percent != 0 THEN 1 ELSE 0 END AS has_frl,
                CASE WHEN od.is_title_1 THEN 1 ELSE 0 END       AS title1,
                x.organization_type_id
         FROM x
                  LEFT JOIN r ON r.organization_id = x.id
                  LEFT JOIN p ON p.organization_id = x.id
                  LEFT JOIN l ON l.organization_id = x.id
                  JOIN public.organization_demographics od ON od.organization_id = x.id
         WHERE (r.organization_id IS NOT NULL OR p.organization_id IS NOT NULL OR
                l.organization_id IS NOT NULL)
     ) y
         JOIN live_data.organization_types ot ON ot.id = y.organization_type_id
GROUP BY ot.name;
