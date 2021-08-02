CREATE OR REPLACE FUNCTION sp_org_assessment_benchmark_dates(_set_id integer, _table character varying, _choice character varying)
    RETURNS TABLE
            (
                organization_id integer,
                benchmark_date  date
            )
    LANGUAGE plpgsql
AS
$$
DECLARE
    criterion_instances_rec RECORD;
    benchmark_choice        character varying;
    sql_str                 text;

BEGIN
    sql_str := '';
    FOR criterion_instances_rec IN SELECT handle
                                   FROM live_data.criterion_instances
                                   WHERE set_id = _set_id
                                     AND deleted_at IS NULL
                                   ORDER BY handle
        LOOP

            RAISE NOTICE 'handle %', criterion_instances_rec.handle;
            sql_str := sql_str || '"' || LOWER(criterion_instances_rec.handle) || '_date", ';

            RAISE NOTICE 'str %', sql_str;

        END LOOP;
    sql_str := TRIM(TRAILING ', ' FROM sql_str);

    IF (LOWER(_choice) = 'start') THEN
        benchmark_choice := 'LEAST';
    ELSEIF (LOWER(_choice) = 'update') THEN
        benchmark_choice := 'GREATEST';
    ELSE
        RAISE EXCEPTION 'Error: please use "start" or "update" only (no quotes, all lowercase)';
    END IF;

    RETURN QUERY EXECUTE 'SELECT organization_id, ' || benchmark_choice || '(' || sql_str ||
                         ')::date AS benchmark_date FROM ' || _table;

END;
$$;

ALTER FUNCTION sp_org_assessment_benchmark_dates(integer, varchar, varchar) OWNER TO main;

