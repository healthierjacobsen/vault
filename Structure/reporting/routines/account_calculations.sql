CREATE OR REPLACE FUNCTION account_calculations(_last_refresh date) RETURNS void
    LANGUAGE plpgsql
AS
$$
DECLARE
    rec RECORD;
BEGIN

    -- default the queries to use live_data schema unless specified
    SET search_path TO live_data;

    -- clear previous run from output table
    TRUNCATE crm.account_enrollment_date;
    TRUNCATE crm.account_last_activity;
    TRUNCATE crm.account_action_plan_start;
    TRUNCATE crm.account_action_plan_update;
    TRUNCATE crm.account_calculations;

    --------------------- enrollment date
    INSERT INTO crm.account_enrollment_date (p2orgid, online_enrollment_date)
    SELECT o.id,
           MIN(ou.created_at)
    FROM live_data.organizations o
             JOIN live_data.organization_user ou ON o.id = ou.organization_id
        AND ou.organization_role_id = 200-- team members only
        AND ou.created_at >= '2018-09-26'
        AND o.online_enrollment_date IS NULL
    WHERE o.deleted_at IS NULL
    GROUP BY o.id
    ON CONFLICT (p2orgid) DO-- if row already exists
        UPDATE SET online_enrollment_date = EXCLUDED.online_enrollment_date;
    -- update row with date
    --------------------- end enrollment date

    --------------------- last_activity_hsp
    INSERT INTO crm.account_last_activity (p2orgid, last_activity_hsp)
    SELECT o.id,
           MAX(ua.active_at)
    FROM live_data.organizations o
             JOIN live_data.organization_user ou ON o.id = ou.organization_id
        AND ou.organization_role_id = 200
             JOIN live_data.user_activities ua ON ua.user_id = ou.user_id AND ua.active_at >= _last_refresh
    WHERE o.deleted_at IS NULL
    GROUP BY o.id
    ON CONFLICT (p2orgid) DO UPDATE SET last_activity_hsp = EXCLUDED.last_activity_hsp;
    --------------------- end last_activity_hsp

    --------------------- action plan start
    INSERT INTO crm.account_action_plan_start (p2orgid, action_plan_start)
    SELECT o.id,
           MIN(pi.created_at)
    FROM live_data.organizations o
             JOIN live_data.plans p ON p.organization_id = o.id AND p.deleted_at IS NULL
             JOIN live_data.plan_items pi ON p.id = pi.plan_id AND pi.created_at >= _last_refresh
    WHERE o.deleted_at IS NULL
    GROUP BY o.id
    ON CONFLICT (p2orgid) DO UPDATE SET action_plan_start = EXCLUDED.action_plan_start;
    --------------------- end action plan start

    --------------------- action plan update
    INSERT INTO crm.account_action_plan_update (p2orgid, action_plan_update)
    SELECT o.id,
           MAX(pi.updated_at)
    FROM live_data.organizations o
             JOIN live_data.plans p ON p.organization_id = o.id AND p.deleted_at IS NULL
             JOIN live_data.plan_items pi ON p.id = pi.plan_id AND pi.updated_at >= _last_refresh
    WHERE o.deleted_at IS NULL
    GROUP BY o.id
    ON CONFLICT (p2orgid) DO UPDATE SET action_plan_update = EXCLUDED.action_plan_update;
    --------------------- end action plan update


    --------------------- web team config

    DROP TABLE IF EXISTS change_log_temp;
    CREATE TEMP TABLE change_log_temp AS -- creating view of change log data so next query runs faster
    SELECT CAST(row_data ->> 'organization_id' AS INTEGER)      AS organization_id,
           CAST(row_data ->> 'organization_role_id' AS INTEGER) AS organization_role_id
    FROM live_data.change_log
    WHERE table_name = 'organization_user'
      AND action_type = 'DELETE';

    WITH x AS (
        SELECT o.id,
               COUNT(ou.organization_role_id = 100 OR NULL) AS count_guests,
               COUNT(ou.organization_role_id = 200 OR NULL) AS count_team_members,
               COUNT(ou.organization_role_id = 300 OR NULL) AS count_onsite_managers,
               COUNT(ou.organization_role_id = 400 OR NULL) AS count_virtual_managers
        FROM live_data.organizations o
                 LEFT JOIN live_data.organization_user ou ON o.id = ou.organization_id
            AND o.deleted_at IS NULL -- limiting to active accounts
        GROUP BY o.id
    )

    INSERT
    INTO crm.account_calculations (p2orgid, web_team_config)
    SELECT DISTINCT x.id    AS p2orgid,
                    CASE
                        WHEN (x.count_guests > 0 AND x.count_team_members = 0) THEN 124680001 -- Guests Only
                        WHEN x.count_team_members > 0 THEN 124680002 -- Has Team Members
                        WHEN (x.count_guests = 0 AND x.count_team_members = 0 AND
                              cl.organization_id IS NOT NULL AND cl.organization_role_id IN (100, 200))
                            THEN 124680003 -- Previously Had Users
                        WHEN (x.count_guests = 0 AND x.count_team_members = 0 AND x.count_onsite_managers = 0 AND
                              x.count_virtual_managers = 0 AND
                              cl.organization_id IS NULL) THEN 124680000 -- No Users Ever
                        WHEN (x.count_guests = 0 AND x.count_team_members = 0 AND x.count_onsite_managers = 0 AND
                              x.count_virtual_managers = 0 AND
                              cl.organization_id IS NOT NULL AND cl.organization_role_id IN (300, 400))
                            THEN 124680005 --Previous AHG Staff Only
                        WHEN (x.count_guests = 0 AND x.count_team_members = 0 AND
                              (x.count_onsite_managers > 0 OR x.count_virtual_managers > 0) AND
                              (cl.organization_id IS NULL OR
                               (cl.organization_id IS NOT NULL AND cl.organization_role_id NOT IN (100, 200))))
                            THEN 124680004 --Current AHG Staff Only
                        END AS web_team_config
    FROM x
             LEFT JOIN (
        SELECT organization_id, MIN(organization_role_id) AS organization_role_id
        FROM change_log_temp
        GROUP BY organization_id
    ) AS cl ON x.id = cl.organization_id
         --JOIN live_data.organizations o ON o.id = x.id AND o.deleted_at IS NULL
    ON CONFLICT (p2orgid) DO UPDATE SET web_team_config = EXCLUDED.web_team_config;

    DELETE
    FROM crm.account_calculations
    WHERE p2orgid IN (SELECT id FROM live_data.organizations WHERE deleted_at IS NOT NULL);

    --------------------- end web team config

    --------------------- award eligibility
    INSERT INTO crm.account_calculations (p2orgid, award_eligibility)
    SELECT o.id                   AS p2orgid,
           kw.program_eligibility AS award_eligibility
    FROM public.kw_fy20_ahs_eligibility kw
             JOIN live_data.organizations o ON kw.pid = o.pid
    WHERE o.deleted_at IS NULL -- limiting to active accounts
    ON CONFLICT (p2orgid) DO UPDATE SET award_eligibility = EXCLUDED.award_eligibility;
    --------------------- end award eligibility

    --------------------- benchmarks
    FOR rec IN SELECT * FROM live_data.sets WHERE deleted_at IS NULL AND crm_id IS NOT NULL ORDER BY id
        LOOP
            RAISE NOTICE 'Starting benchmark calculations for %', rec.id;
            PERFORM public.sp_calculate_benchmarks(rec.id);
        END LOOP;

END
$$;

ALTER FUNCTION account_calculations(date) OWNER TO main;

