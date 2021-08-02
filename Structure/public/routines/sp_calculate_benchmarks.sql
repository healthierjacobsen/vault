CREATE OR REPLACE FUNCTION sp_calculate_benchmarks(_set_id integer) RETURNS void
    LANGUAGE plpgsql
AS
$$
DECLARE
    set_record  RECORD;
    before_date DATE;

BEGIN
    SELECT INTO set_record * FROM live_data.sets WHERE id = _set_id;

    PERFORM public.sp_assessment_baseline_responses(set_record.program_id, set_record.id,
                                                    set_record.organization_type_id, before_date);
    RAISE NOTICE 'baseline_responses sp complete';

    PERFORM public.sp_latest_responses(set_record.program_id, set_record.id, set_record.organization_type_id,
                                       before_date);
    RAISE NOTICE 'latest_responses sp complete';

    INSERT INTO crm.ahg_assesement_benchmark
    (ahg_account, ahg_assessment, ahg_assessmentbenchmarkid, ahg_baselinedate, ahg_name, ahg_startdate, ahg_updatedate,
     createdby, createdon, modifiedby, modifiedon, ownerid, owningbusinessunit, owningteam, owninguser, statecode,
     statuscode)
    SELECT o.crm_site_id                                                                             AS ahg_account,
           set_record.crm_id                                                                         AS ahg_assessment,
           NULL                                                                                      AS ahg_assessmentbenchmarkid,
           q1.baselinedate                                                                           AS ahg_baselinedate,
           CONCAT(q1.organization_id, ' - ', set_record.abbreviation, ' (', set_record.version, ')') AS ahg_name,
           CASE WHEN q1.startdate > set_record.created_at THEN q1.startdate ELSE NULL END            AS ahg_startdate,
           CASE WHEN q1.updatedate > q1.startdate THEN q1.updatedate ELSE NULL END                   AS ahg_updatedate,
           NULL                                                                                      AS createdby,
           NULL                                                                                      AS createdon,
           NULL                                                                                      AS modifiedby,
           NULL                                                                                      AS modifiedon,
           NULL                                                                                      AS ownerid,
           NULL                                                                                      AS owningbusinessunit,
           NULL                                                                                      AS owningteam,
           NULL                                                                                      AS owninguser,
           0                                                                                         AS statecode,
           1                                                                                         AS statuscode
    FROM (
             SELECT br.organization_id,
                    br.pid,
                    spsd.benchmark_date   AS startdate,
                    spud.benchmark_date   AS updatedate,
                    spb.baseline_all_date AS baselinedate
             FROM baseline_responses_ct br
                      JOIN temp_baseline_responses_mod_baselines_ct brct ON br.organization_id = brct.id
                      JOIN latest_responses_ct lr ON br.organization_id = lr.organization_id
                      JOIN public.sp_org_assessment_benchmark_dates(set_record.id, 'baseline_responses_ct',
                                                                    'start') spsd
                           ON br.organization_id = spsd.organization_id
                      JOIN public.sp_org_baselined_all(set_record.id, 'temp_baseline_responses_mod_baselines_ct') spb
                           ON br.organization_id = spb.org_id
                      JOIN public.sp_org_assessment_benchmark_dates(set_record.id, 'latest_responses_ct', 'update') spud
                           ON br.organization_id = spud.organization_id
             WHERE br.pid IS NULL
                OR (br.pid NOT ILIKE '%dev%'
                 AND br.pid NOT ILIKE 'demo%')
         ) AS q1
             JOIN live_data.organizations o ON q1.organization_id = o.id
             LEFT JOIN crm.ahg_assesement_benchmark crm ON o.crm_site_id = crm.ahg_account
        AND crm.ahg_assessment = set_record.crm_id
    WHERE crm.ahg_account IS NULL
      AND q1.startdate >= set_record.created_at;
    RAISE NOTICE 'Insert of records is complete';

    UPDATE crm.ahg_assesement_benchmark
    SET ahg_baselinedate = q1.baselinedate,
        ahg_updatedate   = q1.updatedate
    FROM (
             SELECT o.crm_site_id,
                    spb.baseline_all_date AS baselinedate,
                    CASE
                        WHEN spud.benchmark_date > spsd.benchmark_date -- Update date is after start date
                            THEN spud.benchmark_date
                        ELSE NULL
                        END               AS updatedate
             FROM baseline_responses_ct br
                      JOIN temp_baseline_responses_mod_baselines_ct brct ON br.organization_id = brct.id
                      JOIN latest_responses_ct lr ON br.organization_id = lr.organization_id
                      JOIN public.sp_org_baselined_all(set_record.id, 'temp_baseline_responses_mod_baselines_ct') spb
                           ON br.organization_id = spb.org_id
                      JOIN public.sp_org_assessment_benchmark_dates(set_record.id, 'baseline_responses_ct',
                                                                    'start') spsd
                           ON br.organization_id = spsd.organization_id
                      JOIN public.sp_org_assessment_benchmark_dates(set_record.id, 'latest_responses_ct', 'update') spud
                           ON br.organization_id = spud.organization_id
                      JOIN live_data.organizations o ON br.organization_id = o.id
                      JOIN crm.ahg_assesement_benchmark crm ON o.crm_site_id = crm.ahg_account
                 AND crm.ahg_assessment = set_record.crm_id
         ) AS q1
    WHERE ahg_assesement_benchmark.ahg_account = q1.crm_site_id
      AND ahg_assesement_benchmark.ahg_assessment = set_record.crm_id
    -- 		AND (q1.baselinedate > ahg_assesement_benchmark.modifiedon
-- 		    OR q1.updatedate > ahg_assesement_benchmark.modifiedon) -- Only alter records where assessment activity is after most recent CRM modification
    ;
    RAISE NOTICE 'Update of records is complete';

END;
$$;

ALTER FUNCTION sp_calculate_benchmarks(integer) OWNER TO main;

GRANT EXECUTE ON FUNCTION sp_calculate_benchmarks(integer) TO chartio;

