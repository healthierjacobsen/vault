CREATE OR REPLACE FUNCTION sp_assessment_baseline_responses(_program_id integer, _set_id integer, _org_type_id integer,
                                                            _current_date date) RETURNS void
    LANGUAGE plpgsql
AS
$$
DECLARE
    before_date date;
    rec         record;
    str         text;
    org_graded  boolean;
BEGIN
    str := '';
    IF _current_date IS NULL THEN
        before_date = CURRENT_DATE;
    ELSE
        before_date = _current_date;
    END IF;
    RAISE NOTICE 'Starting Baseline';
    SELECT INTO org_graded graded FROM live_data.organization_types WHERE id = _org_type_id;

    -- build temp table of baseline responses
    DROP TABLE IF EXISTS temp_baseline_responses CASCADE;
    IF org_graded THEN
        CREATE TEMPORARY TABLE temp_baseline_responses AS
        SELECT pid,
               organization_id,
               name,
               grade_level_low,
               grade_level_high,
               grade_level_ids,
               handle,
               value,
               created_at
        FROM (SELECT o.pid,
                     r.organization_id,
                     o.name,
                     o.grade_level_low,
                     o.grade_level_high,
                     o.grade_level_ids,
                     ci.handle,
                     rv.value,
                     r.created_at,
                     ROW_NUMBER() OVER ( PARTITION BY r.organization_id, r.criterion_id
                         ORDER BY r.organization_id, r.created_at ASC) AS row_num
              FROM live_data.responses r
                       JOIN live_data.sets s ON s.id = _set_id
                       JOIN live_data.response_values rv ON
                          r.response_value_id = rv.id
                      AND r.created_at BETWEEN s.created_at AND before_date
                       JOIN live_data.organizations o ON
                      o.deleted_at IS NULL
                      AND o.organization_type_id = _org_type_id
                      AND o.id = r.organization_id
                       JOIN live_data.criterion_instances ci
                            ON r.criterion_id = ci.criterion_id AND s.id = ci.set_id AND ci.deleted_at IS NULL
                       JOIN live_data.criterion_grade_level cgl ON cgl.criterion_id = ci.criterion_id
                  AND cgl.grade_level_id IN (SELECT JSON_ARRAY_ELEMENTS_TEXT(o.grade_level_ids))
             ) r
        WHERE r.row_num = 1
        ORDER BY 1, 7;
    ELSE
        CREATE TEMPORARY TABLE temp_baseline_responses AS
        SELECT pid,
               organization_id,
               name,
               grade_level_low,
               grade_level_high,
               grade_level_ids,
               handle,
               value,
               created_at
        FROM (SELECT o.pid,
                     r.organization_id,
                     o.name,
                     o.grade_level_low,
                     o.grade_level_high,
                     o.grade_level_ids,
                     ci.handle,
                     rv.value,
                     r.created_at,
                     ROW_NUMBER() OVER ( PARTITION BY r.organization_id, r.criterion_id
                         ORDER BY r.organization_id, r.created_at ASC) AS row_num
              FROM live_data.responses r
                       JOIN live_data.sets s ON s.id = _set_id
                       JOIN live_data.response_values rv ON
                          r.response_value_id = rv.id
                      AND r.created_at BETWEEN s.created_at AND before_date
                       JOIN live_data.organizations o ON
                      o.deleted_at IS NULL
                      AND o.organization_type_id = _org_type_id
                      AND o.id = r.organization_id
                       JOIN live_data.criterion_instances ci
                            ON r.criterion_id = ci.criterion_id AND s.id = ci.set_id AND ci.deleted_at IS NULL
             ) r
        WHERE r.row_num = 1
        ORDER BY 1, 7;
    END IF;
    ALTER TABLE temp_baseline_responses
        ALTER COLUMN organization_id TYPE integer USING organization_id::int;
    CREATE INDEX temp_baseline_responses_organization_id_index ON temp_baseline_responses (organization_id);

    -- run crosstab functions
    RAISE NOTICE 'Starting Baseline Value Crosstab';
    PERFORM public.sp_responses_value_ct(_set_id, 'temp_baseline_responses');
    RAISE NOTICE 'Starting Baseline Date Crosstab';
    PERFORM public.sp_responses_date_ct(_set_id, 'temp_baseline_responses');

    RAISE NOTICE 'Building Baseline Responses Crosstab Table';
    FOR rec IN SELECT handle
               FROM live_data.criterion_instances
               WHERE set_id = _set_id
                 AND deleted_at IS NULL
               ORDER BY LEFT(handle, 3), weight
        LOOP
            str := str || ' v."' || LOWER(rec.handle) || '", d."' || LOWER(rec.handle) || '_date",';
        END LOOP;
    str := TRIM(TRAILING ',' FROM str);

    DROP TABLE IF EXISTS baseline_responses_ct;
    EXECUTE 'CREATE TEMPORARY TABLE baseline_responses_ct AS
        SELECT l.pid, l.organization_id, l.name, l.grade_level_low, l.grade_level_high, ' || str || '
        FROM (
           SELECT *
           FROM (
                  SELECT *,
                         ROW_NUMBER() OVER ( PARTITION BY organization_id
                           ORDER BY organization_id ) AS row_num
                  FROM temp_baseline_responses
                ) AS s1
           WHERE s1.row_num = 1
        ) l
        LEFT JOIN temp_baseline_responses_value_ct v ON v.id = l.organization_id
        LEFT JOIN temp_baseline_responses_date_ct d ON d.id = l.organization_id;';

    ALTER TABLE baseline_responses_ct
        ALTER COLUMN organization_id TYPE integer USING organization_id::int;
    CREATE INDEX baseline_responses_ct_organization_id_index ON baseline_responses_ct (organization_id);

    RAISE NOTICE 'Starting Module Baselines %', before_date;
    PERFORM public.sp_module_baseline(_set_id, 'temp_baseline_responses', before_date, _org_type_id);

END;
$$;

ALTER FUNCTION sp_assessment_baseline_responses(integer, integer, integer, date) OWNER TO main;

