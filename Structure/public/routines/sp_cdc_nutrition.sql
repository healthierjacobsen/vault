CREATE OR REPLACE FUNCTION sp_cdc_nutrition(_start_date date, _end_date date)
    RETURNS TABLE
            (
                resource_orgs           integer,
                nutrition_fully_meeting integer
            )
    LANGUAGE plpgsql
AS
$$
DECLARE
    nutrition_topic     varchar := 'nutrition_topic';
    resource_accesses   int;
    nutrition_responses int;

BEGIN

    -- schools or districts accessing any resource during the period
    SELECT INTO resource_accesses COUNT(DISTINCT o.id)
    FROM (SELECT ral.user_id
          FROM live_data.resource_access_logs ral
          WHERE ral.logged_at BETWEEN _start_date AND _end_date
            AND ral.access_type_id IN (2, 3)
            AND ral.user_id IS NOT NULL
          UNION
          SELECT ua.user_id
          FROM live_data.user_activities ua
          WHERE ua.active_at BETWEEN _start_date AND _end_date
            AND ua.activity ILIKE '%/resources/%'
         ) AS uu
             JOIN live_data.users u ON u.id = uu.user_id AND u.email NOT LIKE '%@healthiergeneration.org%'
             JOIN live_data.organization_user ou ON ou.user_id = u.id AND ou.access_approved_at IS NOT NULL
             JOIN live_data.organizations o
                  ON o.id = ou.organization_id AND o.is_demo IS FALSE AND o.organization_type_id IN (100, 200)
    WHERE o.deleted_at IS NULL
      AND u.deleted_at IS NULL;


    -- schools with responses of 100% for any criteria in the Nutrition topic, made during the period
    DROP TABLE IF EXISTS nutrition_topic_fully;
    CREATE TEMP TABLE nutrition_topic_fully AS
    SELECT r.organization_id
    FROM live_data.responses r
             JOIN live_data.response_values rv ON r.response_value_id = rv.id AND rv.alignment = 1
             JOIN live_data.criterion_instances ci ON ci.criterion_id = r.criterion_id
             JOIN public.reporting_criteria_groupings rcg
                  ON rcg.criterion_instance_handle = ci.handle AND rcg.topic_grouping = nutrition_topic
    WHERE r.created_at BETWEEN _start_date AND _end_date;


    SELECT INTO nutrition_responses COUNT(DISTINCT o.id)
    FROM live_data.organizations o
             JOIN nutrition_topic_fully ntf ON ntf.organization_id = o.id
    WHERE o.deleted_at IS NULL
      AND o.is_demo = FALSE
      AND o.organization_type_id = 100;
    --       AND o.id IN (
--           SELECT r.organization_id
--           FROM live_data.responses r
--           JOIN live_data.response_values rv ON r.response_value_id = rv.id AND rv.alignment = 1
--           JOIN live_data.criterion_instances ci ON ci.criterion_id = r.criterion_id
--           JOIN public.reporting_criteria_groupings rcg ON rcg.criterion_instance_handle = ci.handle AND rcg.topic_grouping = nutrition_topic
--           WHERE r.created_at BETWEEN _start_date AND _end_date
--           GROUP BY r.organization_id
--     );

    RETURN QUERY SELECT resource_accesses, nutrition_responses;

END
$$;

ALTER FUNCTION sp_cdc_nutrition(date, date) OWNER TO main;

