CREATE OR REPLACE FUNCTION verify_closed_merged(_list_table character varying) RETURNS void
    LANGUAGE plpgsql
AS
$$
DECLARE
    check_rec           RECORD;
    c_response_activity boolean;
    c_plan_activity     boolean;
    c_engagement_check  boolean;
    o_response_activity boolean;
    o_plan_activity     boolean;
    o_engagement_check  boolean;
BEGIN
    /**
      This function checks all closing organizations in the provided MDR table to see if there has been activity in the past 24 months
      If an organization is closing and merging with another then both are checked for activity

      Output is sent to the mdr.close_merge table

      SELECT * FROM mdr.verify_closed_merged('"Listocr_M1705066"'::varchar)

     */

    SET SEARCH_PATH TO mdr;

    TRUNCATE mdr.close_merge;

    -- prepare some temp tables
    DROP TABLE IF EXISTS temp_list_pids CASCADE;
    EXECUTE FORMAT('CREATE TEMPORARY TABLE temp_list_pids AS
    SELECT pid::varchar FROM ' || _list_table || ' WHERE status_bld = ''C''
    UNION ALL
    SELECT mpid::varchar FROM ' || _list_table || ' WHERE status_bld = ''C''');

    CREATE INDEX temp_list_pids_pid_index ON temp_list_pids (pid);
    RAISE NOTICE 'Building temp_activity_responses';
    DROP TABLE IF EXISTS temp_activity_responses CASCADE;
    CREATE TEMPORARY TABLE temp_activity_responses AS
        --     SELECT o.id, COUNT(r.id) > 0 AS count
--     FROM live_data.organizations o
--              JOIN temp_list_pids l ON l.pid = o.pid
--              JOIN live_data.responses r
--                   ON r.organization_id = o.id AND r.created_at > date_trunc('month', CURRENT_DATE) - INTERVAL '2 year'
--     WHERE o.deleted_at IS NULL
--     GROUP BY o.id;
    SELECT o.id, COUNT(r.id) > 0 AS count
    FROM live_data.responses r
             JOIN live_data.organizations o ON r.organization_id = o.id
             JOIN temp_list_pids l ON l.pid = o.pid
    WHERE o.deleted_at IS NULL
      AND r.created_at > DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '2 year'
    GROUP BY o.id;

    CREATE INDEX temp_activity_responses_organization_id_index ON temp_activity_responses (id);
    RAISE NOTICE 'Building temp_activity_plans';
    DROP TABLE IF EXISTS temp_activity_plans CASCADE;
    CREATE TEMPORARY TABLE temp_activity_plans AS
        --     SELECT o.id, COUNT(pi.id) > 0 AS count
--     FROM live_data.organizations o
--              JOIN temp_list_pids l ON l.pid = o.pid
--              JOIN live_data.plans p ON p.organization_id = o.id
--              JOIN live_data.plan_items pi ON pi.plan_id = p.id AND
--                                              (pi.created_at > date_trunc('month', CURRENT_DATE) - INTERVAL '2 year' OR
--                                               pi.updated_at > date_trunc('month', CURRENT_DATE) - INTERVAL '2 year')
--     WHERE o.deleted_at IS NULL
--     GROUP BY o.id;
    SELECT o.id, COUNT(pi.id) > 0 AS count
    FROM live_Data.plan_items pi
             JOIN live_data.plans p ON pi.plan_id = p.id
             JOIN live_data.organizations o ON p.organization_id = o.id
             JOIN temp_list_pids l ON l.pid = o.pid
    WHERE o.deleted_at IS NULL
      AND (pi.created_at > DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '2 year' OR
           pi.updated_at > DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '2 year')

    GROUP BY o.id;

    CREATE INDEX temp_activity_plans_organization_id_index ON temp_activity_plans (id);
    RAISE NOTICE 'Building temp_activity_engagements';
    DROP TABLE IF EXISTS temp_activity_engagements CASCADE;
    CREATE TEMPORARY TABLE temp_activity_engagements AS
        --     SELECT o.id, COUNT(e.ahg_engagementid) > 0 AS count
--     FROM live_data.organizations o
--              JOIN temp_list_pids l ON l.pid = o.pid
--              JOIN crm.engagement e ON e.ahg_account::varchar = o.crm_site_id AND e.statecode = '0'
--     WHERE o.deleted_at IS NULL
--     GROUP BY o.id;
    SELECT o.id, COUNT(e.ahg_engagementid) > 0 AS count
    FROM crm.engagement e
             JOIN live_data.organizations o ON e.ahg_account::varchar = o.crm_site_id
             JOIN temp_list_pids l ON l.pid = o.pid
    WHERE o.deleted_at IS NULL
      AND e.statecode = '0'
    GROUP BY o.id;

    CREATE INDEX temp_activity_engagements_organization_id_index ON temp_activity_engagements (id);
    RAISE NOTICE 'Starting Loop';
    FOR check_rec IN EXECUTE FORMAT('SELECT l.*, o.id AS org_id FROM ' || _list_table ||
                                    ' l JOIN live_data.organizations o ON o.pid = l.pid WHERE l.status_bld = ''C''')
        LOOP

            c_response_activity := NULL;
            c_plan_activity := NULL;
            c_engagement_check := NULL;
            o_response_activity := NULL;
            o_plan_activity := NULL;
            o_engagement_check := NULL;

            -- if closed
            IF check_rec.creason != 'M' THEN
                -- worked on any assessment past 24
                SELECT INTO c_response_activity count FROM temp_activity_responses WHERE id = check_rec.org_id;
                -- action plan past 24
                SELECT INTO c_plan_activity count FROM temp_activity_plans WHERE id = check_rec.org_id;
                -- active engagement record
                SELECT INTO c_engagement_check count FROM temp_activity_engagements WHERE id = check_rec.org_id;

            ELSE
                -- if reassigned
                -- closing
                -- worked on any assessment past 24
                SELECT INTO c_response_activity count FROM temp_activity_responses WHERE id = check_rec.org_id;
                -- action plan past 24
                SELECT INTO c_plan_activity count FROM temp_activity_plans WHERE id = check_rec.org_id;
                -- active engagement record
                SELECT INTO c_engagement_check count FROM temp_activity_engagements WHERE id = check_rec.org_id;

                IF check_rec.mpid != '0' THEN
                    -- staying open
                    -- worked on any assessment past 24
                    SELECT INTO o_response_activity count
                    FROM temp_activity_responses tar
                    WHERE tar.id = (SELECT id FROM live_data.organizations WHERE pid = check_rec.mpid);
                    --                     JOIN live_data.organizations o ON o.pid = check_rec.mpid::varchar
--                     WHERE tar.id = o.id;
                    --                 WHERE id = check_rec.org_id;
                    -- action plan past 24
                    SELECT INTO o_plan_activity count
                    FROM temp_activity_plans tap
                    WHERE tap.id = (SELECT id FROM live_data.organizations WHERE pid = check_rec.mpid);
                    --                     JOIN live_data.organizations o ON o.pid = check_rec.mpid::varchar
--                     WHERE tap.id = o.id;
                    --                 WHERE id = check_rec.org_id;
                    -- active engagement record
                    SELECT INTO o_engagement_check count
                    FROM temp_activity_engagements tae
                    WHERE tae.id = (SELECT id FROM live_data.organizations WHERE pid = check_rec.mpid);
                    --                     JOIN live_data.organizations o ON o.pid = check_rec.mpid::varchar
--                     WHERE tae.id = o.id;
                    --                 WHERE id = check_rec.org_id;
                ELSE
                    o_response_activity := 0;
                    o_plan_activity := 0;
                    o_engagement_check := 0;
                END IF;

            END IF;

            INSERT INTO mdr.close_merge
            (id, pid, status, reason, assessment_activity, plan_activity, engagement_record, merged_assessment_activity,
             merged_plan_activity, merged_engagement_record, check_needed)
            VALUES (check_rec.org_id, check_rec.pid, check_rec.status_bld, check_rec.creason, c_response_activity,
                    c_plan_activity,
                    c_engagement_check, o_response_activity, o_plan_activity, o_engagement_check, CASE
                                                                                                      WHEN (COALESCE(c_response_activity::int, 0) +
                                                                                                            COALESCE(c_plan_activity::int, 0) +
                                                                                                            COALESCE(c_engagement_check::int, 0) +
                                                                                                            COALESCE(o_response_activity::int, 0) +
                                                                                                            COALESCE(o_plan_activity::int, 0) +
                                                                                                            COALESCE(o_engagement_check::int, 0)) >
                                                                                                           0 THEN TRUE
                                                                                                      ELSE FALSE END);
        END LOOP;
END;
$$;

ALTER FUNCTION verify_closed_merged(varchar) OWNER TO main;

