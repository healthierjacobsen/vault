CREATE OR REPLACE FUNCTION ever_enrolled_close_accts_excluded(_as_of date)
    RETURNS TABLE
            (
                school_count               integer,
                school_student_count       integer,
                school_high_need_count     integer,
                school_high_need_percent   integer,
                district_count             integer,
                district_student_count     integer,
                district_high_need_count   integer,
                district_high_need_percent integer,
                ost_count                  integer,
                ost_youth_count            integer,
                ost_high_need_count        integer,
                ost_high_need_percent      integer,
                total_children_count       integer
            )
    LANGUAGE plpgsql
AS
$$
DECLARE
    school_count               int;
    school_student_count       int;
    school_w_frl_count         int;
    school_high_need_count     int;
    school_high_need_percent   int;
    district_count             int;
    district_student_count     int;
    district_w_frl_count       int;
    district_high_need_count   int;
    district_high_need_percent int;
    ost_count                  int;
    ost_youth_count            int;
    ost_w_frl_count            int;
    ost_high_need_count        int;
    ost_high_need_percent      int;
    total_children_count       int;
BEGIN

    -- default the queries to use live_data schema unless specified
    SET search_path TO live_data;

    -- prep archived records
    DROP TABLE IF EXISTS change_log_temp;
    CREATE TEMP TABLE change_log_temp AS -- creating view of change log data so next query runs faster
    SELECT CAST(row_data ->> 'user_id' AS INTEGER)              AS user_id,
           CAST(row_data ->> 'organization_id' AS INTEGER)      AS organization_id,
           CAST(row_data ->> 'organization_role_id' AS INTEGER) AS organization_role_id,
           CAST(row_data ->> 'created_at' AS TIMESTAMP)         AS created_at
    FROM live_data.change_log
    WHERE table_name = 'organization_user'
      AND action_type = 'DELETE'
      AND CAST(row_data ->> 'organization_role_id' AS INTEGER) IN (100, 200, 300, 400);

    CREATE INDEX clt_organization_id_index
        ON change_log_temp (organization_id);
    CREATE INDEX clt_user_id_index
        ON change_log_temp (user_id);


    -- count w frl data
    SELECT INTO school_w_frl_count COUNT(x.organization_id)
    FROM (
             SELECT organization_id
             FROM (
                      SELECT o.id AS organization_id
                      FROM live_data.organizations o
                               LEFT JOIN live_data.organization_user ou ON o.id = ou.organization_id
                      WHERE (ou.organization_role_id IN (100, 200, 300, 400) OR
                             o.online_enrollment_date IS NOT NULL)
                        AND o.is_demo = FALSE
                        AND o.organization_type_id IN (100) -- change to org type needed (school = 100, district = 200, ost = 300)
                        AND o.deleted_at IS NULL
                      UNION ALL
                      SELECT clt.organization_id
                      FROM change_log_temp clt
                               JOIN live_data.organizations o ON o.id = clt.organization_id AND
                                                                 o.organization_type_id IN
                                                                 (100) -- change to org type needed (school = 100, district = 200, ost = 300)
                      WHERE o.is_demo = FALSE
                        AND o.deleted_at IS NULL
                  ) u_org
             GROUP BY u_org.organization_id
         ) x
             JOIN public.organization_demographics od ON x.organization_id = od.organization_id
    WHERE od.frl_percent != 0;


    -- total schools reached to date
    -- schools that have ever had guest, team_member, or pm as of date
    WITH s AS (
        SELECT x.organization_id,
               od.school_year_enrollment                 AS enrollment,
               CASE WHEN od.is_title_1 THEN 1 ELSE 0 END AS title1
        FROM (
                 SELECT MIN(u_org.created_at) AS created_at, u_org.organization_id
                 FROM (
                          SELECT o.id                       AS organization_id,
                                 CASE
                                     WHEN o.online_enrollment_date IS NOT NULL THEN CASE
                                                                                        WHEN ou.created_at < o.online_enrollment_date
                                                                                            THEN ou.created_at
                                                                                        ELSE o.online_enrollment_date END
                                     ELSE ou.created_at END AS created_at
                          FROM live_data.organizations o
                                   LEFT JOIN live_data.organization_user ou ON o.id = ou.organization_id
                          WHERE (ou.organization_role_id IN (100, 200, 300, 400) OR
                                 o.online_enrollment_date IS NOT NULL)
                            AND o.is_demo = FALSE
                            AND o.organization_type_id IN (100) -- change to org type needed (school = 100, district = 200, ost = 300)
                            AND o.deleted_at IS NULL
                          UNION ALL
                          SELECT clt.organization_id, clt.created_at
                          FROM change_log_temp clt
                                   JOIN live_data.organizations o ON o.id = clt.organization_id AND
                                                                     o.organization_type_id IN
                                                                     (100) -- change to org type needed (school = 100, district = 200, ost = 300)
                          WHERE o.is_demo = FALSE
                            AND o.deleted_at IS NULL
                      ) u_org
                 GROUP BY u_org.organization_id
             ) x
                 JOIN public.organization_demographics od ON x.organization_id = od.organization_id
        WHERE x.created_at < _as_of
    )
    SELECT INTO school_count, school_student_count, school_high_need_count, school_high_need_percent COUNT(organization_id),
                                                                                                     SUM(enrollment),
                                                                                                     SUM(title1),
                                                                                                     ((SUM(title1) / school_w_frl_count::float) * 100)
    FROM s;
    RAISE NOTICE 'school count %', school_count;
    RAISE NOTICE 'school student count %', school_student_count;
    RAISE NOTICE 'school high need count %', school_high_need_count;
    RAISE NOTICE 'school high need percent %', school_high_need_percent;

    -- count w frl data
    SELECT INTO district_w_frl_count COUNT(x.organization_id)
    FROM (
             SELECT organization_id
             FROM (
                      SELECT o.id AS organization_id
                      FROM live_data.organizations o
                               LEFT JOIN live_data.organization_user ou ON o.id = ou.organization_id
                      WHERE (ou.organization_role_id IN (100, 200, 300, 400) OR
                             o.online_enrollment_date IS NOT NULL)
                        AND o.is_demo = FALSE
                        AND o.organization_type_id IN (200) -- change to org type needed (school = 100, district = 200, ost = 300)
                        AND o.deleted_at IS NULL
                      UNION ALL
                      SELECT clt.organization_id
                      FROM change_log_temp clt
                               JOIN live_data.organizations o ON o.id = clt.organization_id AND
                                                                 o.organization_type_id IN
                                                                 (200) -- change to org type needed (school = 100, district = 200, ost = 300)
                      WHERE o.is_demo = FALSE
                        AND o.deleted_at IS NULL
                  ) u_org
             GROUP BY u_org.organization_id
         ) x
             JOIN public.organization_demographics od ON x.organization_id = od.organization_id
    WHERE od.frl_percent != 0;


    -- total districts reached to date
    -- districts that have ever had guest, team_member, or pm as of date
    WITH s AS (
        SELECT x.organization_id,
               od.school_year_enrollment                 AS enrollment,
               CASE WHEN od.is_title_1 THEN 1 ELSE 0 END AS title1
        FROM (
                 SELECT MIN(u_org.created_at) AS created_at, u_org.organization_id
                 FROM (
                          SELECT o.id                       AS organization_id,
                                 CASE
                                     WHEN o.online_enrollment_date IS NOT NULL THEN CASE
                                                                                        WHEN ou.created_at < o.online_enrollment_date
                                                                                            THEN ou.created_at
                                                                                        ELSE o.online_enrollment_date END
                                     ELSE ou.created_at END AS created_at
                          FROM live_data.organizations o
                                   LEFT JOIN live_data.organization_user ou ON o.id = ou.organization_id
                          WHERE (ou.organization_role_id IN (100, 200, 300, 400) OR
                                 o.online_enrollment_date IS NOT NULL)
                            AND o.is_demo = FALSE
                            AND o.organization_type_id IN (200) -- change to org type needed (school = 100, district = 200, ost = 300)
                            AND o.deleted_at IS NULL
                          UNION ALL
                          SELECT clt.organization_id, clt.created_at
                          FROM change_log_temp clt
                                   JOIN live_data.organizations o ON o.id = clt.organization_id AND
                                                                     o.organization_type_id IN
                                                                     (200) -- change to org type needed (school = 100, district = 200, ost = 300)
                          WHERE o.is_demo = FALSE
                            AND o.deleted_at IS NULL
                      ) u_org
                 GROUP BY u_org.organization_id
             ) x
                 JOIN public.organization_demographics od ON x.organization_id = od.organization_id
        WHERE x.created_at < _as_of
    )
    SELECT INTO district_count, district_student_count, district_high_need_count, district_high_need_percent COUNT(organization_id),
                                                                                                             SUM(enrollment),
                                                                                                             SUM(title1),
                                                                                                             ((SUM(title1) / district_w_frl_count::float) * 100)
    FROM s;
    RAISE NOTICE 'district count %', district_count;
    RAISE NOTICE 'district student count %', district_student_count;
    RAISE NOTICE 'district high need count %', district_high_need_count;
    RAISE NOTICE 'district high need percent %', district_high_need_percent;

    -- total sites reached to date
    -- sites that have ever had guest, team_member, or pm as of date
    WITH h AS (
        SELECT o.id
        FROM live_data.organizations o
                 LEFT JOIN live_data.organization_user ou ON o.id = ou.organization_id
            AND ou.organization_role_id IN (100, 200, 300, 400)
            AND ou.created_at < _as_of
                 LEFT JOIN change_log_temp clt ON o.id = clt.organization_id AND clt.created_at < _as_of
        WHERE o.organization_type_id = 300 -- ost
          AND (ou.organization_id IS NOT NULL OR clt.organization_id IS NOT NULL)
          AND o.deleted_at IS NULL
        GROUP BY o.id
    )
    SELECT INTO ost_count COUNT(id)
    FROM h;
    RAISE NOTICE 'ost count %', ost_count;

    -- total youth reached to date
    SELECT INTO ost_youth_count SUM(enrollment)
    FROM (
             SELECT o.id,
                    CASE
                        WHEN ost."student_enrollment_SY"::int > ost.summer_enrollment::int
                            THEN ost."student_enrollment_SY"::int
                        ELSE ost.summer_enrollment::int END AS enrollment
             FROM live_data.organizations o
                      JOIN public."ost_enrollment_frl" ost ON o.id = ost."p2OrgID"
                      LEFT JOIN live_data.organization_user ou ON o.id = ou.organization_id
                 AND ou.organization_role_id IN (100, 200, 300, 400)
                 AND ou.created_at < _as_of
                      LEFT JOIN change_log_temp clt
                                ON o.id = clt.organization_id AND clt.created_at < _as_of
             WHERE o.organization_type_id = 300 -- ost
               AND (ou.organization_id IS NOT NULL OR clt.organization_id IS NOT NULL)
               AND o.deleted_at IS NULL
             GROUP BY o.id, ost."student_enrollment_SY", ost.summer_enrollment
         ) x;

    RAISE NOTICE 'ost youth count %', ost_youth_count;

    -- percent of sites serving high-need populations (frl >= 40)
    SELECT INTO ost_high_need_count COUNT(1)
    FROM (
             SELECT o.id
             FROM live_data.organizations o
                      JOIN public."ost_enrollment_frl" ost ON o.id = ost."p2OrgID" AND ost.frl_percent::int >= 40
                      LEFT JOIN live_data.organization_user ou ON o.id = ou.organization_id
                 AND ou.organization_role_id IN (100, 200, 300, 400)
                 AND ou.created_at < _as_of
                      LEFT JOIN change_log_temp clt
                                ON o.id = clt.organization_id AND clt.created_at < _as_of
             WHERE o.organization_type_id = 300 -- ost
               AND (ou.organization_id IS NOT NULL OR clt.organization_id IS NOT NULL)
               AND o.deleted_at IS NULL
             GROUP BY o.id
         ) x;

    SELECT INTO ost_w_frl_count COUNT(1)
    FROM (
             SELECT o.id
             FROM live_data.organizations o
                      JOIN public.ost_enrollment_frl ost ON o.id = ost."p2OrgID" AND ost.frl_percent IS NOT NULL
                      LEFT JOIN live_data.organization_user ou ON o.id = ou.organization_id
                 AND ou.organization_role_id IN (100, 200, 300, 400)
                 AND ou.created_at < _as_of
                      LEFT JOIN change_log_temp clt
                                ON o.id = clt.organization_id AND clt.created_at < _as_of
             WHERE o.organization_type_id = 300 -- ost
               AND (ou.organization_id IS NOT NULL OR clt.organization_id IS NOT NULL)
               AND o.deleted_at IS NULL
             GROUP BY o.id
         ) x;

    ost_high_need_percent := ((ost_high_need_count / ost_w_frl_count::float) * 100)::int;

    RAISE NOTICE 'ost high need count %', ost_high_need_count;
    RAISE NOTICE 'ost w/ frl count %', ost_w_frl_count;
    RAISE NOTICE 'ost high need percent %', ost_high_need_percent;

    -- total children impacted

    total_children_count := school_student_count + ost_youth_count;

    RETURN QUERY SELECT school_count,
                        school_student_count,
                        school_high_need_count,
                        school_high_need_percent,
                        district_count,
                        district_student_count,
                        district_high_need_count,
                        district_high_need_percent,
                        ost_count,
                        ost_youth_count,
                        ost_high_need_count,
                        ost_high_need_percent,
                        total_children_count;

END
$$;

ALTER FUNCTION ever_enrolled_close_accts_excluded(date) OWNER TO main;

