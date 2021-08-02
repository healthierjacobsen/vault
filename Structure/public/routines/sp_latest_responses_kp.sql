CREATE OR REPLACE FUNCTION sp_latest_responses_kp(_program_id integer, _set_id integer, _org_type_id integer,
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

    SELECT INTO org_graded graded FROM live_data.organization_types WHERE id = _org_type_id;

    -- build temp table of latest responses
    DROP TABLE IF EXISTS temp_latest_responses CASCADE;
    IF org_graded THEN
        CREATE TEMPORARY TABLE temp_latest_responses AS
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
                     CASE WHEN r.created_at < '2018-01-01' THEN '2018-01-01' ELSE r.created_at END AS created_at,
                     ROW_NUMBER() OVER ( PARTITION BY r.organization_id, r.criterion_id
                         ORDER BY r.organization_id,
                             --CASE WHEN r.created_at < '2018-01-01' THEN '2018-01-01' ELSE r.created_at END DESC
                             r.created_at DESC
                         )                                                                         AS row_num
              FROM live_data.responses r
                       JOIN live_data.response_values rv ON
                          r.response_value_id = rv.id
                      AND r.created_at < before_date
                       JOIN live_data.organizations o ON
                      o.deleted_at IS NULL
                      AND o.organization_type_id = _org_type_id
                      AND o.id = r.organization_id
                       JOIN live_data.criterion_instances ci
                            ON r.criterion_id = ci.criterion_id AND _set_id = ci.set_id AND ci.deleted_at IS NULL
                       JOIN live_data.criterion_grade_level cgl ON cgl.criterion_id = ci.criterion_id
                  AND cgl.grade_level_id IN (SELECT JSON_ARRAY_ELEMENTS_TEXT(o.grade_level_ids))
             ) r
        WHERE r.row_num = 1
        ORDER BY 1, 7;
    ELSE
        CREATE TEMPORARY TABLE temp_latest_responses AS
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
                     CASE WHEN r.created_at < '2018-01-01' THEN '2018-01-01' ELSE r.created_at END AS created_at,
                     ROW_NUMBER() OVER ( PARTITION BY r.organization_id, r.criterion_id
                         ORDER BY r.organization_id,
                             --CASE WHEN r.created_at < '2018-01-01' THEN '2018-01-01' ELSE r.created_at END DESC
                             r.created_at DESC
                         )                                                                         AS row_num
              FROM live_data.responses r
                       JOIN live_data.response_values rv ON
                          r.response_value_id = rv.id
                      AND r.created_at < before_date
                       JOIN live_data.organizations o ON
                      o.deleted_at IS NULL
                      AND o.organization_type_id = _org_type_id
                      AND o.id = r.organization_id
                       JOIN live_data.criterion_instances ci
                            ON r.criterion_id = ci.criterion_id AND _set_id = ci.set_id AND ci.deleted_at IS NULL
             ) r
        WHERE r.row_num = 1
        ORDER BY 1, 7;
    END IF;

    ALTER TABLE temp_latest_responses
        ALTER COLUMN organization_id TYPE integer USING organization_id::int;
    CREATE INDEX temp_latest_responses_organization_id_index ON temp_latest_responses (organization_id);

    -- run crosstab functions
    PERFORM public.sp_responses_value_ct(_set_id, 'temp_latest_responses');
    PERFORM public.sp_responses_date_ct(_set_id, 'temp_latest_responses');

    FOR rec IN SELECT handle
               FROM live_data.criterion_instances
               WHERE set_id = _set_id
                 AND deleted_at IS NULL
               ORDER BY LEFT(handle, 3), weight
        LOOP
            str := str || ' v."' || LOWER(rec.handle) || '", d."' || LOWER(rec.handle) || '_date",';
        END LOOP;
    str := TRIM(TRAILING ',' FROM str);

    DROP TABLE IF EXISTS latest_responses_ct;
    EXECUTE 'CREATE TEMPORARY TABLE latest_responses_ct AS
        SELECT l.pid, l.organization_id, l.name, l.grade_level_low, l.grade_level_high, ' || str || '
        FROM (
           SELECT *
           FROM (
                  SELECT *,
                         ROW_NUMBER() OVER ( PARTITION BY organization_id
                           ORDER BY organization_id ) AS row_num
                  FROM temp_latest_responses
                ) AS s1
           WHERE s1.row_num = 1
        ) l
        LEFT JOIN temp_latest_responses_value_ct v ON v.id = l.organization_id
        LEFT JOIN temp_latest_responses_date_ct d ON d.id = l.organization_id;';

    ALTER TABLE latest_responses_ct
        ALTER COLUMN organization_id TYPE integer USING organization_id::int;
    CREATE INDEX latest_responses_ct_organization_id_index ON latest_responses_ct (organization_id);

    PERFORM public.sp_module_baseline(_set_id, 'temp_latest_responses', before_date, _org_type_id);

END;
$$;

ALTER FUNCTION sp_latest_responses_kp(integer, integer, integer, date) OWNER TO main;

GRANT EXECUTE ON FUNCTION sp_latest_responses_kp(integer, integer, integer, date) TO chartio;
