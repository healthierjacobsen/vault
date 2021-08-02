CREATE OR REPLACE FUNCTION sp_responses_value_ct(_set_id integer, _table character varying) RETURNS void
    LANGUAGE plpgsql
AS
$$
DECLARE
    rec RECORD;
    DECLARE
    str text;
BEGIN
    RAISE NOTICE 'Starting sp_response_value_ct %', _table;
    str := '"id" int, ';
    -- looping to get column heading string
    FOR rec IN SELECT handle
               FROM live_data.criterion_instances
               WHERE set_id = _set_id
                 AND deleted_at IS NULL
               ORDER BY LEFT(handle, 3), weight
        LOOP
            str := str || '"' || LOWER(rec.handle) || '" text' || ',';
        END LOOP;
    str := SUBSTRING(str, 0, LENGTH(str));

    RAISE NOTICE 'test str % and table %', str, _table;

    EXECUTE 'DROP TABLE IF EXISTS ' || _table || '_value_ct;
        CREATE TEMPORARY TABLE ' || _table || '_value_ct AS
        SELECT *
        FROM public.crosstab(''select organization_id as id, handle, value from ' || _table || ' order by 1'',
                     ''SELECT handle
            FROM live_data.criterion_instances
            WHERE set_id = ' || _set_id || ' AND deleted_at IS NULL
           ORDER BY left(handle, 3), weight'')
             AS final_result (' || str || ')';
    RAISE NOTICE 'Completed sp_response_value_ct %', _table;
END;
$$;

ALTER FUNCTION sp_responses_value_ct(integer, varchar) OWNER TO main;

