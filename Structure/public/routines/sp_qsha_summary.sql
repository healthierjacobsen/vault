CREATE OR REPLACE FUNCTION sp_qsha_summary(_end_date date)
    RETURNS TABLE
            (
                school_start                integer,
                school_complete             integer,
                school_any_mod              integer,
                sfa_baselined               integer,
                smh_baselined               integer,
                spa_baselined               integer,
                ssh_baselined               integer,
                ste_baselined               integer,
                rise_school_start           integer,
                rise_school_complete        integer,
                rise_school_any_mod         integer,
                rise_sfa_baselined          integer,
                rise_smh_baselined          integer,
                rise_spa_baselined          integer,
                rise_ssh_baselined          integer,
                rise_ste_baselined          integer,
                hsp_school_start            integer,
                hsp_school_complete         integer,
                hsp_school_any_mod          integer,
                hsp_sfa_baselined           integer,
                hsp_smh_baselined           integer,
                hsp_spa_baselined           integer,
                hsp_ssh_baselined           integer,
                hsp_ste_baselined           integer,
                no_onsite_school_start      integer,
                no_onsite_school_complete   integer,
                no_onsite_school_any_mod    integer,
                no_onsite_sfa_baselined     integer,
                no_onsite_smh_baselined     integer,
                no_onsite_spa_baselined     integer,
                no_onsite_ssh_baselined     integer,
                no_onsite_ste_baselined     integer,
                title1_school_start         integer,
                title1_school_complete      integer,
                title1_school_any_mod       integer,
                title1_sfa_baselined        integer,
                title1_smh_baselined        integer,
                title1_spa_baselined        integer,
                title1_ssh_baselined        integer,
                title1_ste_baselined        integer,
                maj_min_school_start        integer,
                maj_min_school_complete     integer,
                maj_min_school_any_mod      integer,
                maj_min_sfa_baselined       integer,
                maj_min_smh_baselined       integer,
                maj_min_spa_baselined       integer,
                maj_min_ssh_baselined       integer,
                maj_min_ste_baselined       integer,
                district_start              integer,
                district_complete           integer,
                district_any_mod            integer,
                dfa_baselined               integer,
                dmh_baselined               integer,
                dpa_baselined               integer,
                dsh_baselined               integer,
                dte_baselined               integer,
                rise_district_start         integer,
                rise_district_complete      integer,
                rise_district_any_mod       integer,
                rise_dfa_baselined          integer,
                rise_dmh_baselined          integer,
                rise_dpa_baselined          integer,
                rise_dsh_baselined          integer,
                rise_dte_baselined          integer,
                hsp_district_start          integer,
                hsp_district_complete       integer,
                hsp_district_any_mod        integer,
                hsp_dfa_baselined           integer,
                hsp_dmh_baselined           integer,
                hsp_dpa_baselined           integer,
                hsp_dsh_baselined           integer,
                hsp_dte_baselined           integer,
                no_onsite_district_start    integer,
                no_onsite_district_complete integer,
                no_onsite_district_any_mod  integer,
                no_onsite_dfa_baselined     integer,
                no_onsite_dmh_baselined     integer,
                no_onsite_dpa_baselined     integer,
                no_onsite_dsh_baselined     integer,
                no_onsite_dte_baselined     integer,
                title1_district_start       integer,
                title1_district_complete    integer,
                title1_district_any_mod     integer,
                title1_dfa_baselined        integer,
                title1_dmh_baselined        integer,
                title1_dpa_baselined        integer,
                title1_dsh_baselined        integer,
                title1_dte_baselined        integer,
                maj_min_district_start      integer,
                maj_min_district_complete   integer,
                maj_min_district_any_mod    integer,
                maj_min_dfa_baselined       integer,
                maj_min_dmh_baselined       integer,
                maj_min_dpa_baselined       integer,
                maj_min_dsh_baselined       integer,
                maj_min_dte_baselined       integer
            )
    LANGUAGE plpgsql
AS
$$
DECLARE
    school_start                int := 0;
    school_complete             int := 0;
    school_any_mod              int := 0;
    ste_baselined               integer;
    ssh_baselined               integer;
    smh_baselined               integer;
    spa_baselined               integer;
    sfa_baselined               integer;
    rise_school_start           int := 0;
    rise_school_complete        int := 0;
    rise_school_any_mod         int := 0;
    rise_ste_baselined          integer;
    rise_ssh_baselined          integer;
    rise_smh_baselined          integer;
    rise_spa_baselined          integer;
    rise_sfa_baselined          integer;
    hsp_school_start            int := 0;
    hsp_school_complete         int := 0;
    hsp_school_any_mod          int := 0;
    hsp_ste_baselined           integer;
    hsp_ssh_baselined           integer;
    hsp_smh_baselined           integer;
    hsp_spa_baselined           integer;
    hsp_sfa_baselined           integer;
    no_onsite_school_start      int := 0;
    no_onsite_school_complete   int := 0;
    no_onsite_school_any_mod    int := 0;
    no_onsite_ste_baselined     integer;
    no_onsite_ssh_baselined     integer;
    no_onsite_smh_baselined     integer;
    no_onsite_spa_baselined     integer;
    no_onsite_sfa_baselined     integer;
    title1_school_start         int := 0;
    title1_school_complete      int := 0;
    title1_school_any_mod       int := 0;
    title1_ste_baselined        integer;
    title1_ssh_baselined        integer;
    title1_smh_baselined        integer;
    title1_spa_baselined        integer;
    title1_sfa_baselined        integer;
    maj_min_school_start        int := 0;
    maj_min_school_complete     int := 0;
    maj_min_school_any_mod      int := 0;
    maj_min_ste_baselined       integer;
    maj_min_ssh_baselined       integer;
    maj_min_smh_baselined       integer;
    maj_min_spa_baselined       integer;
    maj_min_sfa_baselined       integer;
    district_start              int := 0;
    district_complete           int := 0;
    district_any_mod            int := 0;
    dte_baselined               integer;
    dsh_baselined               integer;
    dmh_baselined               integer;
    dpa_baselined               integer;
    dfa_baselined               integer;
    rise_district_start         int := 0;
    rise_district_complete      int := 0;
    rise_district_any_mod       int := 0;
    rise_dte_baselined          integer;
    rise_dsh_baselined          integer;
    rise_dmh_baselined          integer;
    rise_dpa_baselined          integer;
    rise_dfa_baselined          integer;
    hsp_district_start          int := 0;
    hsp_district_complete       int := 0;
    hsp_district_any_mod        int := 0;
    hsp_dte_baselined           integer;
    hsp_dsh_baselined           integer;
    hsp_dmh_baselined           integer;
    hsp_dpa_baselined           integer;
    hsp_dfa_baselined           integer;
    no_onsite_district_start    int := 0;
    no_onsite_district_complete int := 0;
    no_onsite_district_any_mod  int := 0;
    no_onsite_dte_baselined     integer;
    no_onsite_dsh_baselined     integer;
    no_onsite_dmh_baselined     integer;
    no_onsite_dpa_baselined     integer;
    no_onsite_dfa_baselined     integer;
    title1_district_start       int := 0;
    title1_district_complete    int := 0;
    title1_district_any_mod     int := 0;
    title1_dte_baselined        integer;
    title1_dsh_baselined        integer;
    title1_dmh_baselined        integer;
    title1_dpa_baselined        integer;
    title1_dfa_baselined        integer;
    maj_min_district_start      int := 0;
    maj_min_district_complete   int := 0;
    maj_min_district_any_mod    int := 0;
    maj_min_dte_baselined       integer;
    maj_min_dsh_baselined       integer;
    maj_min_dmh_baselined       integer;
    maj_min_dpa_baselined       integer;
    maj_min_dfa_baselined       integer;
BEGIN

    -- 7 School QS Assessment
    -- 8 District QS Assessment

    -- # of schools that started the assessment
    SELECT INTO school_start, rise_school_start, hsp_school_start, no_onsite_school_start, title1_school_start, maj_min_school_start COUNT(DISTINCT o.id),
                                                                                                                                     COUNT(
                                                                                                                                     DISTINCT
                                                                                                                                     o.id)
                                                                                                                                     FILTER (WHERE
                                                                                                                                             (e.statecode::int = 0)
                                                                                                                                             AND
                                                                                                                                             e.ahg_program =
                                                                                                                                             (SELECT ahg_program FROM crm.ahg_program WHERE p2_program_id = 3000)-- rise program
                                                                                                                                             AND
                                                                                                                                             e.ahg_supporttype::int =
                                                                                                                                             124680000),
                                                                                                                                     COUNT(
                                                                                                                                     DISTINCT
                                                                                                                                     o.id)
                                                                                                                                     FILTER (WHERE
                                                                                                                                             (e.statecode::int = 0)
                                                                                                                                             AND
                                                                                                                                             e.ahg_program =
                                                                                                                                             (SELECT ahg_program FROM crm.ahg_program WHERE p2_program_id = 1000)-- hsp program
                                                                                                                                             AND
                                                                                                                                             e.ahg_supporttype::int =
                                                                                                                                             124680000),
                                                                                                                                     COUNT(
                                                                                                                                     DISTINCT
                                                                                                                                     o.id)
                                                                                                                                     FILTER (WHERE
                                                                                                                                             NOT EXISTS(SELECT *
                                                                                                                                                        FROM crm.engagement eng
                                                                                                                                                        WHERE eng.ahg_account::varchar = o.crm_site_id
                                                                                                                                                          AND eng.statecode::int = 0
                                                                                                                                                          AND e.ahg_supporttype::int = 124680000) OR
                                                                                                                                             EXISTS(SELECT *
                                                                                                                                                    FROM crm.engagement eng
                                                                                                                                                    WHERE eng.ahg_account::varchar = o.crm_site_id
                                                                                                                                                      AND eng.statecode::int = 0
                                                                                                                                                      AND e.ahg_supporttype::int = 124680001)),-- no record, inactive, or supporttype is not onsite
                                                                                                                                     COUNT(DISTINCT o.id) FILTER (WHERE od.is_title_1),
                                                                                                                                     COUNT(DISTINCT o.id) FILTER (WHERE od.is_majority_minority)
    FROM live_data.sets s
             JOIN live_data.criterion_instances ci ON ci.set_id = s.id
             JOIN live_data.organizations o ON o.organization_type_id = s.organization_type_id
             LEFT JOIN live_data.organization_types ot ON ot.id = o.organization_type_id
             LEFT JOIN live_data.v_criterion_grade_level cgl
                       ON o.grade_level_ids::jsonb ? cgl.grade_level_id AND cgl.criterion_id = ci.criterion_id
             JOIN live_data.responses r ON r.criterion_id = ci.criterion_id AND r.organization_id = o.id
             LEFT JOIN crm.engagement e ON e.ahg_account::varchar = o.crm_site_id
             LEFT JOIN public.organization_demographics od ON od.organization_id = o.id
    WHERE s.id = 7
      AND o.organization_type_id = 100
      AND o.is_demo = FALSE
      AND o.deleted_at IS NULL
      AND r.created_at <= _end_date
      AND (ot.graded = FALSE OR cgl.criterion_id IS NOT NULL);

    -- # of schools that completed the assessment
    PERFORM public.sp_baseline_responses(5000, 7, 100, _end_date);
    SELECT INTO school_complete, rise_school_complete, hsp_school_complete, no_onsite_school_complete, title1_school_complete, maj_min_school_complete COUNT(DISTINCT o.id),
                                                                                                                                                       COUNT(
                                                                                                                                                       DISTINCT
                                                                                                                                                       o.id)
                                                                                                                                                       FILTER (WHERE
                                                                                                                                                               (e.statecode::int = 0)
                                                                                                                                                               AND
                                                                                                                                                               e.ahg_program =
                                                                                                                                                               (SELECT ahg_program FROM crm.ahg_program WHERE p2_program_id = 3000)-- rise program
                                                                                                                                                               AND
                                                                                                                                                               e.ahg_supporttype::int =
                                                                                                                                                               124680000),
                                                                                                                                                       COUNT(
                                                                                                                                                       DISTINCT
                                                                                                                                                       o.id)
                                                                                                                                                       FILTER (WHERE
                                                                                                                                                               (e.statecode::int = 0)
                                                                                                                                                               AND
                                                                                                                                                               e.ahg_program =
                                                                                                                                                               (SELECT ahg_program FROM crm.ahg_program WHERE p2_program_id = 1000)-- hsp program
                                                                                                                                                               AND
                                                                                                                                                               e.ahg_supporttype::int =
                                                                                                                                                               124680000),
                                                                                                                                                       COUNT(
                                                                                                                                                       DISTINCT
                                                                                                                                                       o.id)
                                                                                                                                                       FILTER (WHERE
                                                                                                                                                               NOT EXISTS(SELECT *
                                                                                                                                                                          FROM crm.engagement eng
                                                                                                                                                                          WHERE eng.ahg_account::varchar = o.crm_site_id
                                                                                                                                                                            AND eng.statecode::int = 0
                                                                                                                                                                            AND e.ahg_supporttype::int = 124680000) OR
                                                                                                                                                               EXISTS(SELECT *
                                                                                                                                                                      FROM crm.engagement eng
                                                                                                                                                                      WHERE eng.ahg_account::varchar = o.crm_site_id
                                                                                                                                                                        AND eng.statecode::int = 0
                                                                                                                                                                        AND e.ahg_supporttype::int = 124680001)),-- no record, inactive, or supporttype is not onsite
                                                                                                                                                       COUNT(DISTINCT o.id) FILTER (WHERE od.is_title_1),
                                                                                                                                                       COUNT(DISTINCT o.id) FILTER (WHERE od.is_majority_minority)
    FROM baseline_responses_ct br
             JOIN live_data.organizations o ON o.id = br.organization_id
             JOIN temp_baseline_responses_mod_baselines_ct brm ON brm.id = br.organization_id
             JOIN public.sp_org_baselined_all(7, 'temp_baseline_responses_mod_baselines_ct') ba
                  ON ba.org_id = br.organization_id
             LEFT JOIN crm.engagement e ON e.ahg_account::varchar = o.crm_site_id
             JOIN public.organization_demographics od ON od.organization_id = o.id
    WHERE baseline_all_date IS NOT NULL
      AND o.is_demo = FALSE
      AND o.deleted_at IS NULL;

    -- # of schools that baselined each module
    SELECT INTO ste_baselined, ssh_baselined, smh_baselined, spa_baselined, sfa_baselined,
        rise_ste_baselined, rise_ssh_baselined, rise_smh_baselined, rise_spa_baselined, rise_sfa_baselined,
        hsp_ste_baselined, hsp_ssh_baselined, hsp_smh_baselined, hsp_spa_baselined, hsp_sfa_baselined,
        no_onsite_ste_baselined, no_onsite_ssh_baselined, no_onsite_smh_baselined, no_onsite_spa_baselined, no_onsite_sfa_baselined,
        title1_ste_baselined, title1_ssh_baselined, title1_smh_baselined, title1_spa_baselined, title1_sfa_baselined,
        maj_min_ste_baselined, maj_min_ssh_baselined, maj_min_smh_baselined, maj_min_spa_baselined, maj_min_sfa_baselined COUNT(DISTINCT o.id) FILTER ( WHERE mb.ste_baselined = TRUE ),
                                                                                                                          COUNT(DISTINCT o.id) FILTER ( WHERE mb.ssh_baselined = TRUE ),
                                                                                                                          COUNT(DISTINCT o.id) FILTER ( WHERE mb.smh_baselined = TRUE ),
                                                                                                                          COUNT(DISTINCT o.id) FILTER ( WHERE mb.spa_baselined = TRUE ),
                                                                                                                          COUNT(DISTINCT o.id) FILTER ( WHERE mb.sfa_baselined = TRUE ),

                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE
                                                                                                                                      mb.ste_baselined =
                                                                                                                                      TRUE AND
                                                                                                                                      (e.statecode::int = 0)
                                                                                                                                  AND
                                                                                                                                      e.ahg_program =
                                                                                                                                      (SELECT ahg_program FROM crm.ahg_program WHERE p2_program_id = 3000)-- rise program
                                                                                                                                  AND
                                                                                                                                      e.ahg_supporttype::int =
                                                                                                                                      124680000),
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE
                                                                                                                                      mb.ssh_baselined =
                                                                                                                                      TRUE AND
                                                                                                                                      (e.statecode::int = 0)
                                                                                                                                  AND
                                                                                                                                      e.ahg_program =
                                                                                                                                      (SELECT ahg_program FROM crm.ahg_program WHERE p2_program_id = 3000)-- rise program
                                                                                                                                  AND
                                                                                                                                      e.ahg_supporttype::int =
                                                                                                                                      124680000),
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE
                                                                                                                                      mb.smh_baselined =
                                                                                                                                      TRUE AND
                                                                                                                                      (e.statecode::int = 0)
                                                                                                                                  AND
                                                                                                                                      e.ahg_program =
                                                                                                                                      (SELECT ahg_program FROM crm.ahg_program WHERE p2_program_id = 3000)-- rise program
                                                                                                                                  AND
                                                                                                                                      e.ahg_supporttype::int =
                                                                                                                                      124680000),
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE
                                                                                                                                      mb.spa_baselined =
                                                                                                                                      TRUE AND
                                                                                                                                      (e.statecode::int = 0)
                                                                                                                                  AND
                                                                                                                                      e.ahg_program =
                                                                                                                                      (SELECT ahg_program FROM crm.ahg_program WHERE p2_program_id = 3000)-- rise program
                                                                                                                                  AND
                                                                                                                                      e.ahg_supporttype::int =
                                                                                                                                      124680000),
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE
                                                                                                                                      mb.sfa_baselined =
                                                                                                                                      TRUE AND
                                                                                                                                      (e.statecode::int = 0)
                                                                                                                                  AND
                                                                                                                                      e.ahg_program =
                                                                                                                                      (SELECT ahg_program FROM crm.ahg_program WHERE p2_program_id = 3000)-- rise program
                                                                                                                                  AND
                                                                                                                                      e.ahg_supporttype::int =
                                                                                                                                      124680000),

                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE
                                                                                                                                      mb.ste_baselined =
                                                                                                                                      TRUE AND
                                                                                                                                      (e.statecode::int = 0)
                                                                                                                                  AND
                                                                                                                                      e.ahg_program =
                                                                                                                                      (SELECT ahg_program FROM crm.ahg_program WHERE p2_program_id = 1000)-- hsp program
                                                                                                                                  AND
                                                                                                                                      e.ahg_supporttype::int =
                                                                                                                                      124680000),
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE
                                                                                                                                      mb.ssh_baselined =
                                                                                                                                      TRUE AND
                                                                                                                                      (e.statecode::int = 0)
                                                                                                                                  AND
                                                                                                                                      e.ahg_program =
                                                                                                                                      (SELECT ahg_program FROM crm.ahg_program WHERE p2_program_id = 1000)-- hsp program
                                                                                                                                  AND
                                                                                                                                      e.ahg_supporttype::int =
                                                                                                                                      124680000),
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE
                                                                                                                                      mb.smh_baselined =
                                                                                                                                      TRUE AND
                                                                                                                                      (e.statecode::int = 0)
                                                                                                                                  AND
                                                                                                                                      e.ahg_program =
                                                                                                                                      (SELECT ahg_program FROM crm.ahg_program WHERE p2_program_id = 1000)-- hsp program
                                                                                                                                  AND
                                                                                                                                      e.ahg_supporttype::int =
                                                                                                                                      124680000),
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE
                                                                                                                                      mb.spa_baselined =
                                                                                                                                      TRUE AND
                                                                                                                                      (e.statecode::int = 0)
                                                                                                                                  AND
                                                                                                                                      e.ahg_program =
                                                                                                                                      (SELECT ahg_program FROM crm.ahg_program WHERE p2_program_id = 1000)-- hsp program
                                                                                                                                  AND
                                                                                                                                      e.ahg_supporttype::int =
                                                                                                                                      124680000),
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE
                                                                                                                                      mb.sfa_baselined =
                                                                                                                                      TRUE AND
                                                                                                                                      (e.statecode::int = 0)
                                                                                                                                  AND
                                                                                                                                      e.ahg_program =
                                                                                                                                      (SELECT ahg_program FROM crm.ahg_program WHERE p2_program_id = 1000)-- hsp program
                                                                                                                                  AND
                                                                                                                                      e.ahg_supporttype::int =
                                                                                                                                      124680000),

                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE mb.ste_baselined =
                                                                                                                                         TRUE AND
                                                                                                                                         NOT EXISTS(SELECT *
                                                                                                                                                    FROM crm.engagement eng
                                                                                                                                                    WHERE eng.ahg_account::varchar = o.crm_site_id
                                                                                                                                                      AND eng.statecode::int = 0
                                                                                                                                                      AND e.ahg_supporttype::int = 124680000) OR
                                                                                                                                         EXISTS(SELECT *
                                                                                                                                                FROM crm.engagement eng
                                                                                                                                                WHERE eng.ahg_account::varchar = o.crm_site_id
                                                                                                                                                  AND eng.statecode::int = 0
                                                                                                                                                  AND e.ahg_supporttype::int = 124680001)),-- no record, inactive, or supporttype is not onsite
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE mb.ssh_baselined =
                                                                                                                                         TRUE AND
                                                                                                                                         NOT EXISTS(SELECT *
                                                                                                                                                    FROM crm.engagement eng
                                                                                                                                                    WHERE eng.ahg_account::varchar = o.crm_site_id
                                                                                                                                                      AND eng.statecode::int = 0
                                                                                                                                                      AND e.ahg_supporttype::int = 124680000) OR
                                                                                                                                         EXISTS(SELECT *
                                                                                                                                                FROM crm.engagement eng
                                                                                                                                                WHERE eng.ahg_account::varchar = o.crm_site_id
                                                                                                                                                  AND eng.statecode::int = 0
                                                                                                                                                  AND e.ahg_supporttype::int = 124680001)),-- no record, inactive, or supporttype is not onsite
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE mb.smh_baselined =
                                                                                                                                         TRUE AND
                                                                                                                                         NOT EXISTS(SELECT *
                                                                                                                                                    FROM crm.engagement eng
                                                                                                                                                    WHERE eng.ahg_account::varchar = o.crm_site_id
                                                                                                                                                      AND eng.statecode::int = 0
                                                                                                                                                      AND e.ahg_supporttype::int = 124680000) OR
                                                                                                                                         EXISTS(SELECT *
                                                                                                                                                FROM crm.engagement eng
                                                                                                                                                WHERE eng.ahg_account::varchar = o.crm_site_id
                                                                                                                                                  AND eng.statecode::int = 0
                                                                                                                                                  AND e.ahg_supporttype::int = 124680001)),-- no record, inactive, or supporttype is not onsite
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE mb.spa_baselined =
                                                                                                                                         TRUE AND
                                                                                                                                         NOT EXISTS(SELECT *
                                                                                                                                                    FROM crm.engagement eng
                                                                                                                                                    WHERE eng.ahg_account::varchar = o.crm_site_id
                                                                                                                                                      AND eng.statecode::int = 0
                                                                                                                                                      AND e.ahg_supporttype::int = 124680000) OR
                                                                                                                                         EXISTS(SELECT *
                                                                                                                                                FROM crm.engagement eng
                                                                                                                                                WHERE eng.ahg_account::varchar = o.crm_site_id
                                                                                                                                                  AND eng.statecode::int = 0
                                                                                                                                                  AND e.ahg_supporttype::int = 124680001)),-- no record, inactive, or supporttype is not onsite
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE mb.sfa_baselined =
                                                                                                                                         TRUE AND
                                                                                                                                         NOT EXISTS(SELECT *
                                                                                                                                                    FROM crm.engagement eng
                                                                                                                                                    WHERE eng.ahg_account::varchar = o.crm_site_id
                                                                                                                                                      AND eng.statecode::int = 0
                                                                                                                                                      AND e.ahg_supporttype::int = 124680000) OR
                                                                                                                                         EXISTS(SELECT *
                                                                                                                                                FROM crm.engagement eng
                                                                                                                                                WHERE eng.ahg_account::varchar = o.crm_site_id
                                                                                                                                                  AND eng.statecode::int = 0
                                                                                                                                                  AND e.ahg_supporttype::int = 124680001)),-- no record, inactive, or supporttype is not onsite

                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE mb.ste_baselined = TRUE AND od.is_title_1),
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE mb.ssh_baselined = TRUE AND od.is_title_1),
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE mb.smh_baselined = TRUE AND od.is_title_1),
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE mb.spa_baselined = TRUE AND od.is_title_1),
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE mb.sfa_baselined = TRUE AND od.is_title_1),

                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE mb.ste_baselined = TRUE AND od.is_majority_minority),
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE mb.ssh_baselined = TRUE AND od.is_majority_minority),
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE mb.smh_baselined = TRUE AND od.is_majority_minority),
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE mb.spa_baselined = TRUE AND od.is_majority_minority),
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE mb.sfa_baselined = TRUE AND od.is_majority_minority)
    FROM temp_baseline_responses_mod_baselines_ct mb
             JOIN live_data.organizations o ON o.id = mb.id
             LEFT JOIN crm.engagement e ON e.ahg_account::varchar = o.crm_site_id
             JOIN public.organization_demographics od ON od.organization_id = o.id
    WHERE o.is_demo = FALSE
      AND o.deleted_at IS NULL;

    SELECT INTO school_any_mod, rise_school_any_mod, hsp_school_any_mod, no_onsite_school_any_mod, title1_school_any_mod, maj_min_school_any_mod
                COUNT(DISTINCT o.id) FILTER (
            WHERE (mb.ste_baselined = TRUE OR mb.ssh_baselined = TRUE OR mb.smh_baselined = TRUE OR
                   mb.spa_baselined = TRUE OR mb.sfa_baselined = TRUE)),
                COUNT(DISTINCT o.id) FILTER (
                    WHERE (mb.ste_baselined = TRUE OR mb.ssh_baselined = TRUE OR mb.smh_baselined = TRUE OR
                           mb.spa_baselined = TRUE OR mb.sfa_baselined = TRUE)
                        AND (e.statecode::int = 0)
                        AND e.ahg_program = (SELECT ahg_program FROM crm.ahg_program WHERE p2_program_id = 3000)-- rise program
                        AND e.ahg_supporttype::int = 124680000),                                                                            -- rise
                COUNT(DISTINCT o.id) FILTER (
                    WHERE (mb.ste_baselined = TRUE OR mb.ssh_baselined = TRUE OR mb.smh_baselined = TRUE OR
                           mb.spa_baselined = TRUE OR mb.sfa_baselined = TRUE)
                        AND (e.statecode::int = 0)
                        AND e.ahg_program = (SELECT ahg_program FROM crm.ahg_program WHERE p2_program_id = 1000)-- hsp program
                        AND e.ahg_supporttype::int = 124680000),                                                                            -- hsp
                COUNT(DISTINCT o.id) FILTER (
                    WHERE (mb.ste_baselined = TRUE OR mb.ssh_baselined = TRUE OR mb.smh_baselined = TRUE OR
                           mb.spa_baselined = TRUE OR mb.sfa_baselined = TRUE)
                              AND NOT EXISTS(SELECT *
                                             FROM crm.engagement eng
                                             WHERE eng.ahg_account::varchar = o.crm_site_id
                                               AND eng.statecode::int = 0
                                               AND e.ahg_supporttype::int = 124680000) OR EXISTS(SELECT *
                                                                                                 FROM crm.engagement eng
                                                                                                 WHERE eng.ahg_account::varchar = o.crm_site_id
                                                                                                   AND eng.statecode::int = 0
                                                                                                   AND e.ahg_supporttype::int = 124680001)),-- no record, inactive, or supporttype is not onsite
                COUNT(DISTINCT o.id) FILTER (
                    WHERE (mb.ste_baselined = TRUE OR mb.ssh_baselined = TRUE OR mb.smh_baselined = TRUE OR
                           mb.spa_baselined = TRUE OR mb.sfa_baselined = TRUE)
                        AND od.is_title_1),                                                                                                 -- title1
                COUNT(DISTINCT o.id) FILTER (
                    WHERE (mb.ste_baselined = TRUE OR mb.ssh_baselined = TRUE OR mb.smh_baselined = TRUE OR
                           mb.spa_baselined = TRUE OR mb.sfa_baselined = TRUE)
                        AND od.is_majority_minority)                                                                                        -- maj_min
    FROM temp_baseline_responses_mod_baselines_ct mb
             JOIN live_data.organizations o ON o.id = mb.id
             LEFT JOIN crm.engagement e ON e.ahg_account::varchar = o.crm_site_id
             JOIN public.organization_demographics od ON od.organization_id = o.id
    WHERE o.is_demo = FALSE
      AND o.deleted_at IS NULL;

    -- # of districts that started the assessment
    SELECT INTO district_start, rise_district_start, hsp_district_start, no_onsite_district_start, title1_district_start, maj_min_district_start COUNT(DISTINCT o.id),
                                                                                                                                                 COUNT(
                                                                                                                                                 DISTINCT
                                                                                                                                                 o.id)
                                                                                                                                                 FILTER (WHERE
                                                                                                                                                         (e.statecode::int = 0)
                                                                                                                                                         AND
                                                                                                                                                         e.ahg_program =
                                                                                                                                                         (SELECT ahg_program FROM crm.ahg_program WHERE p2_program_id = 3000)-- rise program
                                                                                                                                                         AND
                                                                                                                                                         e.ahg_supporttype::int =
                                                                                                                                                         124680000),
                                                                                                                                                 COUNT(
                                                                                                                                                 DISTINCT
                                                                                                                                                 o.id)
                                                                                                                                                 FILTER (WHERE
                                                                                                                                                         (e.statecode::int = 0)
                                                                                                                                                         AND
                                                                                                                                                         e.ahg_program =
                                                                                                                                                         (SELECT ahg_program FROM crm.ahg_program WHERE p2_program_id = 1000)-- hsp program
                                                                                                                                                         AND
                                                                                                                                                         e.ahg_supporttype::int =
                                                                                                                                                         124680000),
                                                                                                                                                 COUNT(
                                                                                                                                                 DISTINCT
                                                                                                                                                 o.id)
                                                                                                                                                 FILTER (WHERE
                                                                                                                                                         NOT EXISTS(SELECT *
                                                                                                                                                                    FROM crm.engagement eng
                                                                                                                                                                    WHERE eng.ahg_account::varchar = o.crm_site_id
                                                                                                                                                                      AND eng.statecode::int = 0
                                                                                                                                                                      AND e.ahg_supporttype::int = 124680000) OR
                                                                                                                                                         EXISTS(SELECT *
                                                                                                                                                                FROM crm.engagement eng
                                                                                                                                                                WHERE eng.ahg_account::varchar = o.crm_site_id
                                                                                                                                                                  AND eng.statecode::int = 0
                                                                                                                                                                  AND e.ahg_supporttype::int = 124680001)),-- no record, inactive, or supporttype is not onsite
                                                                                                                                                 COUNT(DISTINCT o.id) FILTER (WHERE od.is_title_1),
                                                                                                                                                 COUNT(DISTINCT o.id) FILTER (WHERE od.is_majority_minority)
    FROM live_data.sets s
             JOIN live_data.criterion_instances ci ON ci.set_id = s.id
             JOIN live_data.organizations o ON o.organization_type_id = s.organization_type_id
             LEFT JOIN live_data.organization_types ot ON ot.id = o.organization_type_id
             LEFT JOIN live_data.v_criterion_grade_level cgl
                       ON o.grade_level_ids::jsonb ? cgl.grade_level_id AND cgl.criterion_id = ci.criterion_id
             JOIN live_data.responses r ON r.criterion_id = ci.criterion_id AND r.organization_id = o.id
             LEFT JOIN crm.engagement e ON e.ahg_account::varchar = o.crm_site_id
             JOIN public.organization_demographics od ON od.organization_id = o.id
    WHERE s.id = 8
      AND o.organization_type_id = 200
      AND o.is_demo = FALSE
      AND o.deleted_at IS NULL
      AND r.created_at <= _end_date
      AND (ot.graded = FALSE OR cgl.criterion_id IS NOT NULL);

    -- # of districts that completed the assessment
    PERFORM public.sp_baseline_responses(5000, 8, 200, _end_date);
    SELECT INTO district_complete, rise_district_complete, hsp_district_complete, no_onsite_district_complete, title1_district_complete, maj_min_district_complete COUNT(DISTINCT o.id),
                                                                                                                                                                   COUNT(
                                                                                                                                                                   DISTINCT
                                                                                                                                                                   o.id)
                                                                                                                                                                   FILTER (WHERE
                                                                                                                                                                           (e.statecode::int = 0)
                                                                                                                                                                           AND
                                                                                                                                                                           e.ahg_program =
                                                                                                                                                                           (SELECT ahg_program FROM crm.ahg_program WHERE p2_program_id = 3000)-- rise program
                                                                                                                                                                           AND
                                                                                                                                                                           e.ahg_supporttype::int =
                                                                                                                                                                           124680000),
                                                                                                                                                                   COUNT(
                                                                                                                                                                   DISTINCT
                                                                                                                                                                   o.id)
                                                                                                                                                                   FILTER (WHERE
                                                                                                                                                                           (e.statecode::int = 0)
                                                                                                                                                                           AND
                                                                                                                                                                           e.ahg_program =
                                                                                                                                                                           (SELECT ahg_program FROM crm.ahg_program WHERE p2_program_id = 1000)-- hsp program
                                                                                                                                                                           AND
                                                                                                                                                                           e.ahg_supporttype::int =
                                                                                                                                                                           124680000),
                                                                                                                                                                   COUNT(
                                                                                                                                                                   DISTINCT
                                                                                                                                                                   o.id)
                                                                                                                                                                   FILTER (WHERE
                                                                                                                                                                           NOT EXISTS(SELECT *
                                                                                                                                                                                      FROM crm.engagement eng
                                                                                                                                                                                      WHERE eng.ahg_account::varchar = o.crm_site_id
                                                                                                                                                                                        AND eng.statecode::int = 0
                                                                                                                                                                                        AND e.ahg_supporttype::int = 124680000) OR
                                                                                                                                                                           EXISTS(SELECT *
                                                                                                                                                                                  FROM crm.engagement eng
                                                                                                                                                                                  WHERE eng.ahg_account::varchar = o.crm_site_id
                                                                                                                                                                                    AND eng.statecode::int = 0
                                                                                                                                                                                    AND e.ahg_supporttype::int = 124680001)),-- no record, inactive, or supporttype is not onsite
                                                                                                                                                                   COUNT(DISTINCT o.id) FILTER (WHERE od.is_title_1),
                                                                                                                                                                   COUNT(DISTINCT o.id) FILTER (WHERE od.is_majority_minority)
    FROM baseline_responses_ct br
             JOIN live_data.organizations o ON o.id = br.organization_id
             JOIN temp_baseline_responses_mod_baselines_ct brm ON brm.id = br.organization_id
             JOIN public.sp_org_baselined_all(8, 'temp_baseline_responses_mod_baselines_ct') ba
                  ON ba.org_id = br.organization_id
             LEFT JOIN crm.engagement e ON e.ahg_account::varchar = o.crm_site_id
             JOIN public.organization_demographics od ON od.organization_id = o.id
    WHERE baseline_all_date IS NOT NULL
      AND o.is_demo = FALSE
      AND o.deleted_at IS NULL;

    -- # of schools that baselined each module
    SELECT INTO dte_baselined, dsh_baselined, dmh_baselined, dpa_baselined, dfa_baselined,
        rise_dte_baselined, rise_dsh_baselined, rise_dmh_baselined, rise_dpa_baselined, rise_dfa_baselined,
        hsp_dte_baselined, hsp_dsh_baselined, hsp_dmh_baselined, hsp_dpa_baselined, hsp_dfa_baselined,
        no_onsite_dte_baselined, no_onsite_dsh_baselined, no_onsite_dmh_baselined, no_onsite_dpa_baselined, no_onsite_dfa_baselined,
        title1_dte_baselined, title1_dsh_baselined, title1_dmh_baselined, title1_dpa_baselined, title1_dfa_baselined,
        maj_min_dte_baselined, maj_min_dsh_baselined, maj_min_dmh_baselined, maj_min_dpa_baselined, maj_min_dfa_baselined COUNT(DISTINCT o.id) FILTER ( WHERE mb.dte_baselined = TRUE ),
                                                                                                                          COUNT(DISTINCT o.id) FILTER ( WHERE mb.dsh_baselined = TRUE ),
                                                                                                                          COUNT(DISTINCT o.id) FILTER ( WHERE mb.dmh_baselined = TRUE ),
                                                                                                                          COUNT(DISTINCT o.id) FILTER ( WHERE mb.dpa_baselined = TRUE ),
                                                                                                                          COUNT(DISTINCT o.id) FILTER ( WHERE mb.dfa_baselined = TRUE ),

                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE
                                                                                                                                      mb.dte_baselined =
                                                                                                                                      TRUE AND
                                                                                                                                      (e.statecode::int = 0)
                                                                                                                                  AND
                                                                                                                                      e.ahg_program =
                                                                                                                                      (SELECT ahg_program FROM crm.ahg_program WHERE p2_program_id = 3000)-- rise program
                                                                                                                                  AND
                                                                                                                                      e.ahg_supporttype::int =
                                                                                                                                      124680000),
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE
                                                                                                                                      mb.dsh_baselined =
                                                                                                                                      TRUE AND
                                                                                                                                      (e.statecode::int = 0)
                                                                                                                                  AND
                                                                                                                                      e.ahg_program =
                                                                                                                                      (SELECT ahg_program FROM crm.ahg_program WHERE p2_program_id = 3000)-- rise program
                                                                                                                                  AND
                                                                                                                                      e.ahg_supporttype::int =
                                                                                                                                      124680000),
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE
                                                                                                                                      mb.dmh_baselined =
                                                                                                                                      TRUE AND
                                                                                                                                      (e.statecode::int = 0)
                                                                                                                                  AND
                                                                                                                                      e.ahg_program =
                                                                                                                                      (SELECT ahg_program FROM crm.ahg_program WHERE p2_program_id = 3000)-- rise program
                                                                                                                                  AND
                                                                                                                                      e.ahg_supporttype::int =
                                                                                                                                      124680000),
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE
                                                                                                                                      mb.dpa_baselined =
                                                                                                                                      TRUE AND
                                                                                                                                      (e.statecode::int = 0)
                                                                                                                                  AND
                                                                                                                                      e.ahg_program =
                                                                                                                                      (SELECT ahg_program FROM crm.ahg_program WHERE p2_program_id = 3000)-- rise program
                                                                                                                                  AND
                                                                                                                                      e.ahg_supporttype::int =
                                                                                                                                      124680000),
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE
                                                                                                                                      mb.dfa_baselined =
                                                                                                                                      TRUE AND
                                                                                                                                      (e.statecode::int = 0)
                                                                                                                                  AND
                                                                                                                                      e.ahg_program =
                                                                                                                                      (SELECT ahg_program FROM crm.ahg_program WHERE p2_program_id = 3000)-- rise program
                                                                                                                                  AND
                                                                                                                                      e.ahg_supporttype::int =
                                                                                                                                      124680000),

                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE
                                                                                                                                      mb.dte_baselined =
                                                                                                                                      TRUE AND
                                                                                                                                      (e.statecode::int = 0)
                                                                                                                                  AND
                                                                                                                                      e.ahg_program =
                                                                                                                                      (SELECT ahg_program FROM crm.ahg_program WHERE p2_program_id = 1000)-- hsp program
                                                                                                                                  AND
                                                                                                                                      e.ahg_supporttype::int =
                                                                                                                                      124680000),
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE
                                                                                                                                      mb.dsh_baselined =
                                                                                                                                      TRUE AND
                                                                                                                                      (e.statecode::int = 0)
                                                                                                                                  AND
                                                                                                                                      e.ahg_program =
                                                                                                                                      (SELECT ahg_program FROM crm.ahg_program WHERE p2_program_id = 1000)-- hsp program
                                                                                                                                  AND
                                                                                                                                      e.ahg_supporttype::int =
                                                                                                                                      124680000),
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE
                                                                                                                                      mb.dmh_baselined =
                                                                                                                                      TRUE AND
                                                                                                                                      (e.statecode::int = 0)
                                                                                                                                  AND
                                                                                                                                      e.ahg_program =
                                                                                                                                      (SELECT ahg_program FROM crm.ahg_program WHERE p2_program_id = 1000)-- hsp program
                                                                                                                                  AND
                                                                                                                                      e.ahg_supporttype::int =
                                                                                                                                      124680000),
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE
                                                                                                                                      mb.dpa_baselined =
                                                                                                                                      TRUE AND
                                                                                                                                      (e.statecode::int = 0)
                                                                                                                                  AND
                                                                                                                                      e.ahg_program =
                                                                                                                                      (SELECT ahg_program FROM crm.ahg_program WHERE p2_program_id = 1000)-- hsp program
                                                                                                                                  AND
                                                                                                                                      e.ahg_supporttype::int =
                                                                                                                                      124680000),
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE
                                                                                                                                      mb.dfa_baselined =
                                                                                                                                      TRUE AND
                                                                                                                                      (e.statecode::int = 0)
                                                                                                                                  AND
                                                                                                                                      e.ahg_program =
                                                                                                                                      (SELECT ahg_program FROM crm.ahg_program WHERE p2_program_id = 1000)-- hsp program
                                                                                                                                  AND
                                                                                                                                      e.ahg_supporttype::int =
                                                                                                                                      124680000),

                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE mb.dte_baselined =
                                                                                                                                         TRUE AND
                                                                                                                                         NOT EXISTS(SELECT *
                                                                                                                                                    FROM crm.engagement eng
                                                                                                                                                    WHERE eng.ahg_account::varchar = o.crm_site_id
                                                                                                                                                      AND eng.statecode::int = 0
                                                                                                                                                      AND e.ahg_supporttype::int = 124680000) OR
                                                                                                                                         EXISTS(SELECT *
                                                                                                                                                FROM crm.engagement eng
                                                                                                                                                WHERE eng.ahg_account::varchar = o.crm_site_id
                                                                                                                                                  AND eng.statecode::int = 0
                                                                                                                                                  AND e.ahg_supporttype::int = 124680001)),-- no record, inactive, or supporttype is not onsite
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE mb.dsh_baselined =
                                                                                                                                         TRUE AND
                                                                                                                                         NOT EXISTS(SELECT *
                                                                                                                                                    FROM crm.engagement eng
                                                                                                                                                    WHERE eng.ahg_account::varchar = o.crm_site_id
                                                                                                                                                      AND eng.statecode::int = 0
                                                                                                                                                      AND e.ahg_supporttype::int = 124680000) OR
                                                                                                                                         EXISTS(SELECT *
                                                                                                                                                FROM crm.engagement eng
                                                                                                                                                WHERE eng.ahg_account::varchar = o.crm_site_id
                                                                                                                                                  AND eng.statecode::int = 0
                                                                                                                                                  AND e.ahg_supporttype::int = 124680001)),-- no record, inactive, or supporttype is not onsite
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE mb.dmh_baselined =
                                                                                                                                         TRUE AND
                                                                                                                                         NOT EXISTS(SELECT *
                                                                                                                                                    FROM crm.engagement eng
                                                                                                                                                    WHERE eng.ahg_account::varchar = o.crm_site_id
                                                                                                                                                      AND eng.statecode::int = 0
                                                                                                                                                      AND e.ahg_supporttype::int = 124680000) OR
                                                                                                                                         EXISTS(SELECT *
                                                                                                                                                FROM crm.engagement eng
                                                                                                                                                WHERE eng.ahg_account::varchar = o.crm_site_id
                                                                                                                                                  AND eng.statecode::int = 0
                                                                                                                                                  AND e.ahg_supporttype::int = 124680001)),-- no record, inactive, or supporttype is not onsite
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE mb.dpa_baselined =
                                                                                                                                         TRUE AND
                                                                                                                                         NOT EXISTS(SELECT *
                                                                                                                                                    FROM crm.engagement eng
                                                                                                                                                    WHERE eng.ahg_account::varchar = o.crm_site_id
                                                                                                                                                      AND eng.statecode::int = 0
                                                                                                                                                      AND e.ahg_supporttype::int = 124680000) OR
                                                                                                                                         EXISTS(SELECT *
                                                                                                                                                FROM crm.engagement eng
                                                                                                                                                WHERE eng.ahg_account::varchar = o.crm_site_id
                                                                                                                                                  AND eng.statecode::int = 0
                                                                                                                                                  AND e.ahg_supporttype::int = 124680001)),-- no record, inactive, or supporttype is not onsite
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE mb.dfa_baselined =
                                                                                                                                         TRUE AND
                                                                                                                                         NOT EXISTS(SELECT *
                                                                                                                                                    FROM crm.engagement eng
                                                                                                                                                    WHERE eng.ahg_account::varchar = o.crm_site_id
                                                                                                                                                      AND eng.statecode::int = 0
                                                                                                                                                      AND e.ahg_supporttype::int = 124680000) OR
                                                                                                                                         EXISTS(SELECT *
                                                                                                                                                FROM crm.engagement eng
                                                                                                                                                WHERE eng.ahg_account::varchar = o.crm_site_id
                                                                                                                                                  AND eng.statecode::int = 0
                                                                                                                                                  AND e.ahg_supporttype::int = 124680001)),-- no record, inactive, or supporttype is not onsite

                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE mb.dte_baselined = TRUE AND od.is_title_1),
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE mb.dsh_baselined = TRUE AND od.is_title_1),
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE mb.dmh_baselined = TRUE AND od.is_title_1),
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE mb.dpa_baselined = TRUE AND od.is_title_1),
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE mb.dfa_baselined = TRUE AND od.is_title_1),

                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE mb.dte_baselined = TRUE AND od.is_majority_minority),
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE mb.dsh_baselined = TRUE AND od.is_majority_minority),
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE mb.dmh_baselined = TRUE AND od.is_majority_minority),
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE mb.dpa_baselined = TRUE AND od.is_majority_minority),
                                                                                                                          COUNT(
                                                                                                                          DISTINCT
                                                                                                                          o.id)
                                                                                                                          FILTER ( WHERE mb.dfa_baselined = TRUE AND od.is_majority_minority)
    FROM temp_baseline_responses_mod_baselines_ct mb
             JOIN live_data.organizations o ON o.id = mb.id
             LEFT JOIN crm.engagement e ON e.ahg_account::varchar = o.crm_site_id
             JOIN public.organization_demographics od ON od.organization_id = o.id
    WHERE o.is_demo = FALSE
      AND o.deleted_at IS NULL;

    SELECT INTO district_any_mod, rise_district_any_mod, hsp_district_any_mod, no_onsite_district_any_mod, title1_district_any_mod, maj_min_district_any_mod
                COUNT(DISTINCT o.id) FILTER (
            WHERE (mb.dte_baselined = TRUE OR mb.dsh_baselined = TRUE OR mb.dmh_baselined = TRUE OR
                   mb.dpa_baselined = TRUE OR mb.dfa_baselined = TRUE)),
                COUNT(DISTINCT o.id) FILTER (
                    WHERE (mb.dte_baselined = TRUE OR mb.dsh_baselined = TRUE OR mb.dmh_baselined = TRUE OR
                           mb.dpa_baselined = TRUE OR mb.dfa_baselined = TRUE)
                        AND (e.statecode::int = 0)
                        AND e.ahg_program = (SELECT ahg_program FROM crm.ahg_program WHERE p2_program_id = 3000)-- rise program
                        AND e.ahg_supporttype::int = 124680000),                                                                            -- rise
                COUNT(DISTINCT o.id) FILTER (
                    WHERE (mb.dte_baselined = TRUE OR mb.dsh_baselined = TRUE OR mb.dmh_baselined = TRUE OR
                           mb.dpa_baselined = TRUE OR mb.dfa_baselined = TRUE)
                        AND (e.statecode::int = 0)
                        AND e.ahg_program = (SELECT ahg_program FROM crm.ahg_program WHERE p2_program_id = 1000)-- hsp program
                        AND e.ahg_supporttype::int = 124680000),                                                                            -- hsp
                COUNT(DISTINCT o.id) FILTER (
                    WHERE (mb.dte_baselined = TRUE OR mb.dsh_baselined = TRUE OR mb.dmh_baselined = TRUE OR
                           mb.dpa_baselined = TRUE OR mb.dfa_baselined = TRUE)
                              AND NOT EXISTS(SELECT *
                                             FROM crm.engagement eng
                                             WHERE eng.ahg_account::varchar = o.crm_site_id
                                               AND eng.statecode::int = 0
                                               AND e.ahg_supporttype::int = 124680000) OR EXISTS(SELECT *
                                                                                                 FROM crm.engagement eng
                                                                                                 WHERE eng.ahg_account::varchar = o.crm_site_id
                                                                                                   AND eng.statecode::int = 0
                                                                                                   AND e.ahg_supporttype::int = 124680001)),-- no record, inactive, or supporttype is not onsite
                COUNT(DISTINCT o.id) FILTER (
                    WHERE (mb.dte_baselined = TRUE OR mb.dsh_baselined = TRUE OR mb.dmh_baselined = TRUE OR
                           mb.dpa_baselined = TRUE OR mb.dfa_baselined = TRUE)
                        AND od.is_title_1),                                                                                                 -- title1
                COUNT(DISTINCT o.id) FILTER (
                    WHERE (mb.dte_baselined = TRUE OR mb.dsh_baselined = TRUE OR mb.dmh_baselined = TRUE OR
                           mb.dpa_baselined = TRUE OR mb.dfa_baselined = TRUE)
                        AND od.is_majority_minority)                                                                                        -- maj_min
    FROM temp_baseline_responses_mod_baselines_ct mb
             JOIN live_data.organizations o ON o.id = mb.id
             LEFT JOIN crm.engagement e ON e.ahg_account::varchar = o.crm_site_id
             JOIN public.organization_demographics od ON od.organization_id = o.id
    WHERE o.is_demo = FALSE
      AND o.deleted_at IS NULL;
    --     SELECT INTO district_complete COUNT(1) FROM baseline_responses_ct br
--     JOIN live_data.organizations o ON o.id = br.organization_id
--     JOIN temp_baseline_responses_mod_baselines_ct brm ON brm.id = br.organization_id
--     JOIN sp_org_baselined_all(8, 'temp_baseline_responses_mod_baselines_ct') ba ON ba.org_id = br.organization_id
--     WHERE baseline_all_date IS NOT NULL AND o.is_demo = false AND o.deleted_at IS NULL
--     ;
--
--     SELECT INTO dte_baselined, dsh_baselined, dmh_baselined, dpa_baselined, dfa_baselined
--                COUNT(1) FILTER ( WHERE mb.dte_baselined = TRUE ) ,
--                COUNT(1) FILTER ( WHERE mb.dsh_baselined = TRUE ) ,
--                COUNT(1) FILTER ( WHERE mb.dmh_baselined = TRUE ) ,
--                COUNT(1) FILTER ( WHERE mb.dpa_baselined = TRUE ) ,
--                COUNT(1) FILTER ( WHERE mb.dfa_baselined = TRUE )
--     FROM temp_baseline_responses_mod_baselines_ct mb
--     JOIN live_data.organizations o ON o.id = mb.id
--     WHERE o.is_demo = false
--       AND o.deleted_at IS NULL
--     ;
--
--     -- # of schools who have started the assessment and are also RISE onsite
--     SELECT INTO school_rise_onsite COUNT(DISTINCT o.id) FROM live_data.sets s
--     JOIN live_data.criterion_instances ci ON ci.set_id = s.id
--     JOIN live_data.organizations o ON o.organization_type_id = s.organization_type_id
--     LEFT JOIN live_data.organization_types ot ON ot.id = o.organization_type_id
--     LEFT JOIN live_data.v_criterion_grade_level cgl ON o.grade_level_ids::jsonb ? cgl.grade_level_id AND cgl.criterion_id = ci.criterion_id
--     JOIN live_data.responses r ON r.criterion_id = ci.criterion_id AND r.organization_id = o.id
--     JOIN crm.engagement e ON e.ahg_account::varchar = o.crm_site_id
--     WHERE s.id = 7
--       AND o.organization_type_id = 100
--       AND o.is_demo = false
--       AND o.deleted_at IS NULL
--       AND r.created_at <= _end_date
--     AND (ot.graded = FALSE OR cgl.criterion_id IS NOT NULL)
--     AND (e.ahg_serviceenddate IS NULL OR e.ahg_serviceenddate > _end_date)
--     AND e.ahg_program = (SELECT ahg_program FROM crm.ahg_program WHERE p2_program_id = 3000)-- rise program
--     AND e.ahg_supporttype::int = 124680000; -- onsite support type
--
--     -- # of schools who have started the assessment and are also HSP onsite
--     SELECT INTO school_hsp_onsite COUNT(DISTINCT o.id) FROM live_data.sets s
--     JOIN live_data.criterion_instances ci ON ci.set_id = s.id
--     JOIN live_data.organizations o ON o.organization_type_id = s.organization_type_id
--     LEFT JOIN live_data.organization_types ot ON ot.id = o.organization_type_id
--     LEFT JOIN live_data.v_criterion_grade_level cgl ON o.grade_level_ids::jsonb ? cgl.grade_level_id AND cgl.criterion_id = ci.criterion_id
--     JOIN live_data.responses r ON r.criterion_id = ci.criterion_id AND r.organization_id = o.id
--     JOIN crm.engagement e ON e.ahg_account::varchar = o.crm_site_id
--     WHERE s.id = 7
--       AND o.organization_type_id = 100
--       AND o.is_demo = false
--       AND o.deleted_at IS NULL
--       AND r.created_at <= _end_date
--     AND (ot.graded = FALSE OR cgl.criterion_id IS NOT NULL)
--     AND (e.ahg_serviceenddate IS NULL OR e.ahg_serviceenddate > _end_date)
--     AND e.ahg_program = (SELECT ahg_program FROM crm.ahg_program WHERE p2_program_id = 1000)-- hsp program
--     AND e.ahg_supporttype::int = 124680000; -- onsite support type
--
--     -- # of schools who have started the assessment and do not have an engagement record
--     SELECT INTO school_no_onsite COUNT(DISTINCT o.id) FROM live_data.sets s
--     JOIN live_data.criterion_instances ci ON ci.set_id = s.id
--     JOIN live_data.organizations o ON o.organization_type_id = s.organization_type_id
--     LEFT JOIN live_data.organization_types ot ON ot.id = o.organization_type_id
--     LEFT JOIN live_data.v_criterion_grade_level cgl ON o.grade_level_ids::jsonb ? cgl.grade_level_id AND cgl.criterion_id = ci.criterion_id
--     JOIN live_data.responses r ON r.criterion_id = ci.criterion_id AND r.organization_id = o.id
--     LEFT JOIN crm.engagement e ON e.ahg_account::varchar = o.crm_site_id
--     WHERE s.id = 7
--       AND o.organization_type_id = 100
--       AND o.is_demo = false
--       AND o.deleted_at IS NULL
--       AND r.created_at <= _end_date
--     AND (ot.graded = FALSE OR cgl.criterion_id IS NOT NULL)
--     AND (e.ahg_account IS NULL OR e.ahg_serviceenddate < _end_date)
--     ;
--
--     -- # of districts who have started the assessment and are also RISE onsite
--     SELECT INTO district_rise_onsite COUNT(DISTINCT o.id) FROM live_data.sets s
--     JOIN live_data.criterion_instances ci ON ci.set_id = s.id
--     JOIN live_data.organizations o ON o.organization_type_id = s.organization_type_id
--     LEFT JOIN live_data.organization_types ot ON ot.id = o.organization_type_id
--     LEFT JOIN live_data.v_criterion_grade_level cgl ON o.grade_level_ids::jsonb ? cgl.grade_level_id AND cgl.criterion_id = ci.criterion_id
--     JOIN live_data.responses r ON r.criterion_id = ci.criterion_id AND r.organization_id = o.id
--     JOIN crm.engagement e ON e.ahg_account::varchar = o.crm_site_id
--     WHERE s.id = 8
--       AND o.organization_type_id = 200
--       AND o.is_demo = false
--       AND o.deleted_at IS NULL
--       AND r.created_at <= _end_date
--     AND (ot.graded = FALSE OR cgl.criterion_id IS NOT NULL)
--     AND (e.ahg_serviceenddate IS NULL OR e.ahg_serviceenddate > _end_date)
--     AND e.ahg_program = (SELECT ahg_program FROM crm.ahg_program WHERE p2_program_id = 3000)-- rise program
--     AND e.ahg_supporttype::int = 124680000; -- onsite support type
--
--     -- # of districts who have started the assessment and are also HSP onsite
--     SELECT INTO district_hsp_onsite COUNT(DISTINCT o.id) FROM live_data.sets s
--     JOIN live_data.criterion_instances ci ON ci.set_id = s.id
--     JOIN live_data.organizations o ON o.organization_type_id = s.organization_type_id
--     LEFT JOIN live_data.organization_types ot ON ot.id = o.organization_type_id
--     LEFT JOIN live_data.v_criterion_grade_level cgl ON o.grade_level_ids::jsonb ? cgl.grade_level_id AND cgl.criterion_id = ci.criterion_id
--     JOIN live_data.responses r ON r.criterion_id = ci.criterion_id AND r.organization_id = o.id
--     JOIN crm.engagement e ON e.ahg_account::varchar = o.crm_site_id
--     WHERE s.id = 8
--       AND o.organization_type_id = 200
--       AND o.is_demo = false
--       AND o.deleted_at IS NULL
--       AND r.created_at <= _end_date
--     AND (ot.graded = FALSE OR cgl.criterion_id IS NOT NULL)
--     AND (e.ahg_serviceenddate IS NULL OR e.ahg_serviceenddate > _end_date)
--     AND e.ahg_program = (SELECT ahg_program FROM crm.ahg_program WHERE p2_program_id = 1000)-- hsp program
--     AND e.ahg_supporttype::int = 124680000; -- onsite support type
--
--     -- # of districts who have started and do not have an engagement record
--     SELECT INTO district_no_onsite COUNT(DISTINCT o.id) FROM live_data.sets s
--     JOIN live_data.criterion_instances ci ON ci.set_id = s.id
--     JOIN live_data.organizations o ON o.organization_type_id = s.organization_type_id
--     LEFT JOIN live_data.organization_types ot ON ot.id = o.organization_type_id
--     LEFT JOIN live_data.v_criterion_grade_level cgl ON o.grade_level_ids::jsonb ? cgl.grade_level_id AND cgl.criterion_id = ci.criterion_id
--     JOIN live_data.responses r ON r.criterion_id = ci.criterion_id AND r.organization_id = o.id
--     LEFT JOIN crm.engagement e ON e.ahg_account::varchar = o.crm_site_id
--     WHERE s.id = 8
--       AND o.organization_type_id = 200
--       AND o.is_demo = false
--       AND o.deleted_at IS NULL
--       AND r.created_at <= _end_date
--     AND (ot.graded = FALSE OR cgl.criterion_id IS NOT NULL)
--      AND (e.ahg_account IS NULL OR e.ahg_serviceenddate < _end_date)
--     ;
--
--     -- # of schools who have started the assessment and are title 1
--     SELECT INTO school_title_1 COUNT(DISTINCT o.id) FROM live_data.sets s
--     JOIN live_data.criterion_instances ci ON ci.set_id = s.id
--     JOIN live_data.organizations o ON o.organization_type_id = s.organization_type_id
--     LEFT JOIN live_data.organization_types ot ON ot.id = o.organization_type_id
--     LEFT JOIN live_data.v_criterion_grade_level cgl ON o.grade_level_ids::jsonb ? cgl.grade_level_id AND cgl.criterion_id = ci.criterion_id
--     JOIN live_data.responses r ON r.criterion_id = ci.criterion_id AND r.organization_id = o.id
--     JOIN public.organization_demographics od ON od.organization_id = o.id
--     WHERE s.id = 7
--       AND o.organization_type_id = 100
--       AND o.is_demo = false
--       AND o.deleted_at IS NULL
--       AND r.created_at <= _end_date
--     AND (ot.graded = FALSE OR cgl.criterion_id IS NOT NULL)
--     AND od.is_title_1
--     ;
--
--         -- # of schools who have started the assessment and are majority minority
--     SELECT INTO school_title_1 COUNT(DISTINCT o.id) FROM live_data.sets s
--     JOIN live_data.criterion_instances ci ON ci.set_id = s.id
--     JOIN live_data.organizations o ON o.organization_type_id = s.organization_type_id
--     LEFT JOIN live_data.organization_types ot ON ot.id = o.organization_type_id
--     LEFT JOIN live_data.v_criterion_grade_level cgl ON o.grade_level_ids::jsonb ? cgl.grade_level_id AND cgl.criterion_id = ci.criterion_id
--     JOIN live_data.responses r ON r.criterion_id = ci.criterion_id AND r.organization_id = o.id
--     JOIN public.organization_demographics od ON od.organization_id = o.id
--     WHERE s.id = 7
--       AND o.organization_type_id = 100
--       AND o.is_demo = false
--       AND o.deleted_at IS NULL
--       AND r.created_at <= _end_date
--     AND (ot.graded = FALSE OR cgl.criterion_id IS NOT NULL)
--     AND od.is_majority_minority
--     ;
--
--     -- # of districts who have started and are title 1
--     SELECT INTO district_title_1 COUNT(DISTINCT o.id) FROM live_data.sets s
--     JOIN live_data.criterion_instances ci ON ci.set_id = s.id
--     JOIN live_data.organizations o ON o.organization_type_id = s.organization_type_id
--     LEFT JOIN live_data.organization_types ot ON ot.id = o.organization_type_id
--     LEFT JOIN live_data.v_criterion_grade_level cgl ON o.grade_level_ids::jsonb ? cgl.grade_level_id AND cgl.criterion_id = ci.criterion_id
--     JOIN live_data.responses r ON r.criterion_id = ci.criterion_id AND r.organization_id = o.id
--     JOIN public.organization_demographics od ON od.organization_id = o.id
--     WHERE s.id = 8
--       AND o.organization_type_id = 200
--       AND o.is_demo = false
--       AND o.deleted_at IS NULL
--       AND r.created_at <= _end_date
--     AND (ot.graded = FALSE OR cgl.criterion_id IS NOT NULL)
--      AND od.is_title_1
--     ;
--
--         -- # of districts who have started the assessment and are majority minority
--     SELECT INTO district_title_1 COUNT(DISTINCT o.id) FROM live_data.sets s
--     JOIN live_data.criterion_instances ci ON ci.set_id = s.id
--     JOIN live_data.organizations o ON o.organization_type_id = s.organization_type_id
--     LEFT JOIN live_data.organization_types ot ON ot.id = o.organization_type_id
--     LEFT JOIN live_data.v_criterion_grade_level cgl ON o.grade_level_ids::jsonb ? cgl.grade_level_id AND cgl.criterion_id = ci.criterion_id
--     JOIN live_data.responses r ON r.criterion_id = ci.criterion_id AND r.organization_id = o.id
--     JOIN public.organization_demographics od ON od.organization_id = o.id
--     WHERE s.id = 8
--       AND o.organization_type_id = 200
--       AND o.is_demo = false
--       AND o.deleted_at IS NULL
--       AND r.created_at <= _end_date
--     AND (ot.graded = FALSE OR cgl.criterion_id IS NOT NULL)
--      AND od.is_majority_minority
--     ;

    RETURN QUERY SELECT school_start,
                        school_complete,
                        school_any_mod,
                        sfa_baselined,
                        smh_baselined,
                        spa_baselined,
                        ssh_baselined,
                        ste_baselined,
                        rise_school_start,
                        rise_school_complete,
                        rise_school_any_mod,
                        rise_sfa_baselined,
                        rise_smh_baselined,
                        rise_spa_baselined,
                        rise_ssh_baselined,
                        rise_ste_baselined,
                        hsp_school_start,
                        hsp_school_complete,
                        hsp_school_any_mod,
                        hsp_sfa_baselined,
                        hsp_smh_baselined,
                        hsp_spa_baselined,
                        hsp_ssh_baselined,
                        hsp_ste_baselined,
                        no_onsite_school_start,
                        no_onsite_school_complete,
                        no_onsite_school_any_mod,
                        no_onsite_sfa_baselined,
                        no_onsite_smh_baselined,
                        no_onsite_spa_baselined,
                        no_onsite_ssh_baselined,
                        no_onsite_ste_baselined,
                        title1_school_start,
                        title1_school_complete,
                        title1_school_any_mod,
                        title1_sfa_baselined,
                        title1_smh_baselined,
                        title1_spa_baselined,
                        title1_ssh_baselined,
                        title1_ste_baselined,
                        maj_min_school_start,
                        maj_min_school_complete,
                        maj_min_school_any_mod,
                        maj_min_sfa_baselined,
                        maj_min_smh_baselined,
                        maj_min_spa_baselined,
                        maj_min_ssh_baselined,
                        maj_min_ste_baselined,
                        district_start,
                        district_complete,
                        district_any_mod,
                        dfa_baselined,
                        dmh_baselined,
                        dpa_baselined,
                        dsh_baselined,
                        dte_baselined,
                        rise_district_start,
                        rise_district_complete,
                        rise_district_any_mod,
                        rise_dfa_baselined,
                        rise_dmh_baselined,
                        rise_dpa_baselined,
                        rise_dsh_baselined,
                        rise_dte_baselined,
                        hsp_district_start,
                        hsp_district_complete,
                        hsp_district_any_mod,
                        hsp_dfa_baselined,
                        hsp_dmh_baselined,
                        hsp_dpa_baselined,
                        hsp_dsh_baselined,
                        hsp_dte_baselined,
                        no_onsite_district_start,
                        no_onsite_district_complete,
                        no_onsite_district_any_mod,
                        no_onsite_dfa_baselined,
                        no_onsite_dmh_baselined,
                        no_onsite_dpa_baselined,
                        no_onsite_dsh_baselined,
                        no_onsite_dte_baselined,
                        title1_district_start,
                        title1_district_complete,
                        title1_district_any_mod,
                        title1_dfa_baselined,
                        title1_dmh_baselined,
                        title1_dpa_baselined,
                        title1_dsh_baselined,
                        title1_dte_baselined,
                        maj_min_district_start,
                        maj_min_district_complete,
                        maj_min_district_any_mod,
                        maj_min_dfa_baselined,
                        maj_min_dmh_baselined,
                        maj_min_dpa_baselined,
                        maj_min_dsh_baselined,
                        maj_min_dte_baselined;

END
$$;

ALTER FUNCTION sp_qsha_summary(date) OWNER TO main;

