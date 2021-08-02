CREATE OR REPLACE FUNCTION sp_bcbs(_start_date date, _end_date date)
    RETURNS TABLE
            (
                total_schools              integer,
                num_assessment_schools     integer,
                per_assessment_schools     double precision,
                num_completed              integer,
                per_completed              double precision,
                num_action_plan            integer,
                per_action_plan            double precision,
                num_improved_pepa          integer,
                num_available_pepa         integer,
                num_improved_nu            integer,
                num_available_nu           integer,
                num_grown_or_po_1          integer,
                per_grown_or_po_1          double precision,
                num_improved_or_fully_po_1 integer,
                per_improved_or_fully_po_1 double precision,
                num_improved_or_fully_po_3 integer,
                per_improved_or_fully_po_3 double precision,
                num_grown                  integer,
                per_grown                  double precision,
                avg_team                   double precision,
                num_improved_ew            integer,
                per_improved_ew            double precision
            )
    LANGUAGE plpgsql
AS
$$
DECLARE
    -- defined variables
    bcbs_guid              uuid    := '61763907-a2c5-e911-a98f-000d3a1087a0';
    pa_module_id           int     := 4;
    nu_module_id           int     := 3;
    ew_module_id           int     := 1;
    po_1_id                int     := 401;
    po_3_id                int     := 403;
    fully_meeting_value    varchar := '3';
    program_id             int     := 1000;
    assessment_id          int     := 1;
    org_type_id            int     := 100;
    team_member_id         int     := 200;
    -- variables for counts and calculations
    num_schools            int;
    num_assessment_schools int;
    per_assessment_schools float;
    num_complete           int;
    avail_complete         int;
    per_complete           float;
    num_plan               int;
    per_plan               float;
    num_improved_pa        int;
    total_avail_pa         int;
    per_improved_pa        float;
    num_improved_ns        int;
    total_avail_ns         int;
    per_improved_ns        float;
    num_team_grown         int;
    num_po_1               int;
    num_po_3               int;
    num_team_grown_or_po_1 int;
    total_team_members     int;
    num_ew_improve         int;
    num_ew_able            int;
BEGIN
    -- lets get the easy stuff out of the way first
    SELECT INTO num_schools COUNT(1)
    FROM live_data.organizations o
             JOIN crm.ahg_account_ahg_grant aaag
                  ON aaag.accountid::varchar = o.crm_site_id AND o.deleted_at IS NULL
                      AND aaag.ahg_grantid = bcbs_guid
                      AND o.organization_type_id = org_type_id;

    SELECT INTO total_team_members COUNT(1)
    FROM live_data.organizations o
             JOIN crm.ahg_account_ahg_grant aaag
                  ON aaag.accountid::varchar = o.crm_site_id AND o.deleted_at IS NULL
                      AND aaag.ahg_grantid = bcbs_guid
                      AND o.organization_type_id = org_type_id
             JOIN live_data.organization_user ou
                  ON ou.organization_id = o.id AND ou.organization_role_id = team_member_id;

    SELECT INTO num_assessment_schools, per_assessment_schools COUNT(aab.vault_id),
                                                               COUNT(aab.vault_id) / num_schools::float
    FROM live_data.organizations o
             JOIN crm.ahg_account_ahg_grant aaag ON aaag.accountid::varchar = o.crm_site_id AND o.deleted_at IS NULL
        AND aaag.ahg_grantid = bcbs_guid
        AND o.organization_type_id = org_type_id
             JOIN live_data.sets s ON s.id = assessment_id
             LEFT JOIN crm.ahg_assesement_benchmark aab
                       ON aab.ahg_account = o.crm_site_id AND aab.ahg_assessment = s.crm_id
    WHERE (aab.ahg_startdate BETWEEN _start_date AND _end_date OR
           aab.ahg_updatedate BETWEEN _start_date AND _end_date);

    SELECT INTO num_complete, avail_complete SUM(CASE
                                                     WHEN aab.ahg_baselinedate IS NOT NULL AND
                                                          aab.ahg_baselinedate BETWEEN _start_date AND _end_date THEN 1
                                                     ELSE 0 END),
                                             SUM(CASE
                                                     WHEN aab.ahg_baselinedate IS NULL OR aab.ahg_baselinedate > _start_date
                                                         THEN 1
                                                     ELSE 0 END)
    FROM live_data.organizations o
             JOIN crm.ahg_account_ahg_grant aaag ON aaag.accountid::varchar = o.crm_site_id AND o.deleted_at IS NULL
        AND aaag.ahg_grantid = bcbs_guid
        AND o.organization_type_id = org_type_id
             JOIN live_data.sets s ON s.id = assessment_id
             LEFT JOIN crm.ahg_assesement_benchmark aab
                       ON aab.ahg_account = o.crm_site_id AND aab.ahg_assessment = s.crm_id;
    RAISE NOTICE 'num_complete %, avail_complete %', num_complete, avail_complete;
    per_complete := num_complete / avail_complete::float;

    SELECT INTO num_plan, per_plan SUM(CASE WHEN p.created_at IS NOT NULL THEN 1 ELSE 0 END),
                                   SUM(CASE WHEN p.created_at IS NOT NULL THEN 1 ELSE 0 END) / num_schools::float
    FROM live_data.organizations o
             JOIN crm.ahg_account_ahg_grant aaag ON aaag.accountid::varchar = o.crm_site_id AND o.deleted_at IS NULL
        AND aaag.ahg_grantid = bcbs_guid
        AND o.organization_type_id = org_type_id
             LEFT JOIN (
        SELECT o.id, MAX(pi.created_at) AS created_at, MAX(pi.updated_at) AS updated_at
        FROM live_data.organizations o
                 JOIN live_data.plans p ON p.organization_id = o.id
                 JOIN live_data.criterion_instances ci ON ci.set_id = assessment_id
                 JOIN live_data.plan_items pi ON ci.criterion_id = pi.criterion_id AND pi.plan_id = p.id
        WHERE pi.created_at BETWEEN _start_date AND _end_date
           OR pi.updated_at BETWEEN _start_date AND _end_date
        GROUP BY o.id
    ) p ON p.id = o.id;

    -- get the latest responses as of the start date
    PERFORM public.sp_latest_responses(program_id, assessment_id, org_type_id, _start_date);
    -- rename the temporary table so the next run doesn't overwrite
    DROP TABLE IF EXISTS bcbs_start_latest_responses;
    ALTER TABLE temp_latest_responses
        RENAME TO bcbs_start_latest_responses;
    ALTER INDEX temp_latest_responses_organization_id_index RENAME TO bcbs_start_latest_responses_organization_id_index;

    -- get the latest responses as of the end date
    PERFORM public.sp_latest_responses(program_id, assessment_id, org_type_id, _end_date);

    -- get any baseline responses during the period
    PERFORM public.sp_baseline_responses(program_id, assessment_id, org_type_id, _end_date);

    -- compare the responses for PE/PA improvements
    WITH c AS (
        SELECT o.id AS org_id, ci.handle
        FROM live_data.organizations o
                 JOIN crm.ahg_account_ahg_grant aaag
                      ON aaag.accountid::varchar = o.crm_site_id AND o.deleted_at IS NULL
                          AND aaag.ahg_grantid = bcbs_guid
                          AND o.organization_type_id = org_type_id
                 JOIN live_data.criterion_instances ci ON ci.set_id = assessment_id
                 JOIN live_data.organization_criteria oc
                      ON oc.criterion_id = ci.criterion_id AND oc.organization_id = o.id
                 JOIN public.reporting_modules rm ON ci.handle = rm.criterion_handle
        WHERE o.deleted_at IS NULL
          AND rm.module = 'pe_pa'
    )
    SELECT INTO total_avail_pa, num_improved_pa COUNT(DISTINCT o.id),
                                                COUNT(DISTINCT o.id)
                                                FILTER (WHERE s.value < e.value OR (b.value < e.value AND b.created_at > _start_date))
    FROM live_data.organizations o
             JOIN crm.ahg_account_ahg_grant aaag
                  ON aaag.accountid::varchar = o.crm_site_id AND o.deleted_at IS NULL
                      AND aaag.ahg_grantid = bcbs_guid
                      AND o.organization_type_id = org_type_id
             JOIN c ON c.org_id = o.id
             LEFT JOIN bcbs_start_latest_responses s ON s.organization_id = o.id AND s.handle = c.handle
             LEFT JOIN temp_baseline_responses b ON b.organization_id = o.id AND b.handle = c.handle
             JOIN temp_latest_responses e ON e.organization_id = o.id AND e.handle = c.handle;
    RAISE NOTICE 'total_avail_pepa %', total_avail_pa;
    per_improved_pa := num_improved_pa / total_avail_pa::float;

    -- compare the responses for NU improvements
    WITH c AS (
        SELECT o.id AS org_id, ci.handle
        FROM live_data.organizations o
                 JOIN crm.ahg_account_ahg_grant aaag
                      ON aaag.accountid::varchar = o.crm_site_id AND o.deleted_at IS NULL
                          AND aaag.ahg_grantid = bcbs_guid
                          AND o.organization_type_id = org_type_id
                 JOIN live_data.criterion_instances ci ON ci.set_id = assessment_id
                 JOIN live_data.organization_criteria oc
                      ON oc.criterion_id = ci.criterion_id AND oc.organization_id = o.id
                 JOIN public.reporting_modules rm ON ci.handle = rm.criterion_handle
        WHERE o.deleted_at IS NULL
          AND rm.module = 'nu'
    )
    SELECT INTO total_avail_ns, num_improved_ns COUNT(DISTINCT o.id),
                                                COUNT(DISTINCT o.id)
                                                FILTER (WHERE s.value < e.value OR (b.value < e.value AND b.created_at > _start_date))
    FROM live_data.organizations o
             JOIN crm.ahg_account_ahg_grant aaag
                  ON aaag.accountid::varchar = o.crm_site_id AND o.deleted_at IS NULL
                      AND aaag.ahg_grantid = bcbs_guid
                      AND o.organization_type_id = org_type_id
             JOIN c ON c.org_id = o.id
             LEFT JOIN bcbs_start_latest_responses s ON s.organization_id = o.id AND s.handle = c.handle
             LEFT JOIN temp_baseline_responses b ON b.organization_id = o.id AND b.handle = c.handle
             LEFT JOIN temp_latest_responses e ON e.organization_id = o.id AND e.handle = c.handle;
    RAISE NOTICE 'total_avail_ns %', total_avail_ns;
    per_improved_ns := num_improved_ns / total_avail_ns::float;

    -- grown team
    SELECT INTO num_team_grown COUNT(DISTINCT (o.id))
    FROM live_data.organizations o
             JOIN crm.ahg_account_ahg_grant aaag
                  ON aaag.accountid::varchar = o.crm_site_id AND o.deleted_at IS NULL
                      AND aaag.ahg_grantid = bcbs_guid
                      AND o.organization_type_id = org_type_id
             JOIN live_data.organization_user ou
                  ON ou.organization_id = o.id AND ou.organization_role_id = team_member_id AND
                     ou.created_at BETWEEN _start_date AND _end_date;

    -- PO-1 improvement or fully meeting
    WITH c AS (
        SELECT o.id AS org_id, ci.handle
        FROM live_data.organizations o
                 JOIN crm.ahg_account_ahg_grant aaag
                      ON aaag.accountid::varchar = o.crm_site_id AND o.deleted_at IS NULL
                          AND aaag.ahg_grantid = bcbs_guid
                          AND o.organization_type_id = org_type_id
                 JOIN live_data.criterion_instances ci ON ci.set_id = assessment_id
                 JOIN live_data.organization_criteria oc
                      ON oc.criterion_id = ci.criterion_id AND oc.organization_id = o.id
        WHERE o.deleted_at IS NULL
          AND ci.handle = 'PO-1'
    )
    SELECT INTO num_po_1 COUNT(DISTINCT o.id)
                         FILTER (WHERE s.value < e.value OR (b.value < e.value AND b.created_at > _start_date) OR
                                       e.value = fully_meeting_value)
    FROM live_data.organizations o
             JOIN crm.ahg_account_ahg_grant aaag
                  ON aaag.accountid::varchar = o.crm_site_id AND o.deleted_at IS NULL
                      AND aaag.ahg_grantid = bcbs_guid
                      AND o.organization_type_id = org_type_id
             JOIN c ON c.org_id = o.id
             LEFT JOIN bcbs_start_latest_responses s ON s.organization_id = o.id AND s.handle = c.handle
             LEFT JOIN temp_baseline_responses b ON b.organization_id = o.id AND b.handle = c.handle
             JOIN temp_latest_responses e ON e.organization_id = o.id AND e.handle = c.handle;

    -- PO-3 improvement or fully meeting
    WITH c AS (
        SELECT o.id AS org_id, ci.handle
        FROM live_data.organizations o
                 JOIN crm.ahg_account_ahg_grant aaag
                      ON aaag.accountid::varchar = o.crm_site_id AND o.deleted_at IS NULL
                          AND aaag.ahg_grantid = bcbs_guid
                          AND o.organization_type_id = org_type_id
                 JOIN live_data.criterion_instances ci ON ci.set_id = assessment_id
                 JOIN live_data.organization_criteria oc
                      ON oc.criterion_id = ci.criterion_id AND oc.organization_id = o.id
        WHERE o.deleted_at IS NULL
          AND ci.handle = 'PO-3'
    )
    SELECT INTO num_po_3 COUNT(DISTINCT o.id)
                         FILTER (WHERE s.value < e.value OR (b.value < e.value AND b.created_at > _start_date) OR
                                       e.value = fully_meeting_value)
    FROM live_data.organizations o
             JOIN crm.ahg_account_ahg_grant aaag
                  ON aaag.accountid::varchar = o.crm_site_id AND o.deleted_at IS NULL
                      AND aaag.ahg_grantid = bcbs_guid
                      AND o.organization_type_id = org_type_id
             JOIN c ON c.org_id = o.id
             LEFT JOIN bcbs_start_latest_responses s ON s.organization_id = o.id AND s.handle = c.handle
             LEFT JOIN temp_baseline_responses b ON b.organization_id = o.id AND b.handle = c.handle
             JOIN temp_latest_responses e ON e.organization_id = o.id AND e.handle = c.handle;

    -- combo of the two above so the orgs are distinct
    WITH c AS (
        SELECT o.id AS org_id, ci.handle
        FROM live_data.organizations o
                 JOIN crm.ahg_account_ahg_grant aaag
                      ON aaag.accountid::varchar = o.crm_site_id AND o.deleted_at IS NULL
                          AND aaag.ahg_grantid = bcbs_guid
                          AND o.organization_type_id = org_type_id
                 JOIN live_data.criterion_instances ci ON ci.set_id = assessment_id
                 JOIN live_data.organization_criteria oc
                      ON oc.criterion_id = ci.criterion_id AND oc.organization_id = o.id
        WHERE o.deleted_at IS NULL
    )
    SELECT INTO num_team_grown_or_po_1 COUNT(DISTINCT id)
    FROM (
             SELECT id
             FROM (SELECT o.id
                   FROM live_data.organizations o
                            JOIN crm.ahg_account_ahg_grant aaag
                                 ON aaag.accountid::varchar = o.crm_site_id AND o.deleted_at IS NULL
                                     AND aaag.ahg_grantid = bcbs_guid
                                     AND o.organization_type_id = org_type_id
                            JOIN live_data.organization_user ou
                                 ON ou.organization_id = o.id AND ou.organization_role_id = team_member_id AND
                                    ou.created_at BETWEEN _start_date AND _end_date) AS oaoi
             UNION
             (
                 SELECT o.id
                 FROM live_data.organizations o
                          JOIN crm.ahg_account_ahg_grant aaag
                               ON aaag.accountid::varchar = o.crm_site_id AND o.deleted_at IS NULL
                                   AND aaag.ahg_grantid = bcbs_guid
                                   AND o.organization_type_id = org_type_id
                          JOIN c ON c.org_id = o.id
                          LEFT JOIN bcbs_start_latest_responses s ON s.organization_id = o.id AND s.handle = c.handle
                          LEFT JOIN temp_baseline_responses b ON b.organization_id = o.id AND b.handle = c.handle
                          JOIN temp_latest_responses e ON e.organization_id = o.id AND e.handle = c.handle
                 WHERE e.handle IN (SELECT handle
                                    FROM live_data.criterion_instances
                                    WHERE criterion_id = po_1_id AND set_id = assessment_id)
                   AND (s.value < e.value OR (b.value < e.value AND b.created_at > _start_date) OR
                        e.value = fully_meeting_value)
             )) x;


    -- total number able to make an improvement for EW module
    -- total number with an improvement for EW module
    WITH c AS (
        SELECT o.id AS org_id, ci.handle
        FROM live_data.organizations o
                 JOIN crm.ahg_account_ahg_grant aaag
                      ON aaag.accountid::varchar = o.crm_site_id AND o.deleted_at IS NULL
                          AND aaag.ahg_grantid = bcbs_guid
                          AND o.organization_type_id = org_type_id
                 JOIN live_data.criterion_instances ci ON ci.set_id = assessment_id
                 JOIN live_data.organization_criteria oc
                      ON oc.criterion_id = ci.criterion_id AND oc.organization_id = o.id
        WHERE o.deleted_at IS NULL
          AND ci.module_id = ew_module_id
    )
    SELECT INTO num_ew_able, num_ew_improve COUNT(DISTINCT o.id) FILTER (WHERE s.value < fully_meeting_value OR
                                                                               (b.value < fully_meeting_value AND b.created_at > _start_date)),
                                            COUNT(DISTINCT o.id)
                                            FILTER (WHERE s.value < e.value OR (b.value < e.value AND b.created_at > _start_date))
    FROM live_data.organizations o
             JOIN crm.ahg_account_ahg_grant aaag
                  ON aaag.accountid::varchar = o.crm_site_id AND o.deleted_at IS NULL
                      AND aaag.ahg_grantid = bcbs_guid
                      AND o.organization_type_id = organization_type_id
             JOIN c ON c.org_id = o.id
             LEFT JOIN bcbs_start_latest_responses s ON s.organization_id = o.id AND s.handle = c.handle
             LEFT JOIN temp_baseline_responses b ON b.organization_id = o.id AND b.handle = c.handle
             JOIN temp_latest_responses e ON e.organization_id = o.id AND e.handle = c.handle;

    -- total number with an improvement for EW module
--     WITH c AS (
--                       SELECT o.id AS org_id, ci.handle
--                       FROM live_data.organizations o
--                                JOIN crm.ahg_account_ahg_grant aaag
--                                     ON aaag.accountid::varchar = o.crm_site_id AND o.deleted_at IS NULL
--                                         AND aaag.ahg_grantid = bcbs_guid
--                                         AND o.organization_type_id = org_type_id
--                                JOIN live_data.criterion_instances ci ON ci.set_id = assessment_id
--                                JOIN live_data.organization_criteria oc ON oc.criterion_id = ci.criterion_id AND oc.organization_id = o.id
--                       WHERE o.deleted_at IS NULL AND ci.module_id = ew_module_id
--                   )
--     SELECT INTO num_ew_improve
--             count(DISTINCT o.id) filter (WHERE s.value < e.value OR (b.value < e.value AND b.created_at > _start_date))
--     FROM live_data.organizations o
--     JOIN crm.ahg_account_ahg_grant aaag
--         ON aaag.accountid::varchar = o.crm_site_id AND o.deleted_at IS NULL
--             AND aaag.ahg_grantid = bcbs_guid
--             AND o.organization_type_id = organization_type_id
--         JOIN c ON c.org_id = o.id
--  LEFT JOIN bcbs_start_latest_responses s ON s.organization_id = o.id AND s.handle = c.handle
--     LEFT JOIN temp_baseline_responses b ON b.organization_id = o.id AND b.handle = c.handle
--     JOIN temp_latest_responses e ON e.organization_id = o.id AND e.handle = c.handle
--     ;

    RETURN QUERY SELECT num_schools,
                        num_assessment_schools,
                        per_assessment_schools,
                        num_complete,
                        per_complete,
                        num_plan,
                        per_plan,
                        num_improved_pa,
                        total_avail_pa,
                        num_improved_ns,
                        total_avail_ns,
                        num_team_grown_or_po_1,
                        (num_team_grown_or_po_1 / num_schools::float),
                        num_po_1,
                        (num_po_1 / num_schools::float),
                        num_po_3,
                        (num_po_3 / num_schools::float),
                        num_team_grown,
                        (num_team_grown / num_schools::float),
                        (total_team_members / num_schools::float),
                        num_ew_improve,
                        (num_ew_improve / num_ew_able::float);

END
$$;

ALTER FUNCTION sp_bcbs(date, date) OWNER TO main;

