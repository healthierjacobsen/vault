CREATE OR REPLACE FUNCTION sp_mod_baselined_ct(_set_id integer, _table character varying) RETURNS void
    LANGUAGE plpgsql
AS
$$
DECLARE
    rec RECORD;
    str text;
BEGIN
    str := '"id" int, ';
    -- looping to get column heading string
    FOR rec IN SELECT abbreviation
               FROM live_data.modules
               WHERE set_id = _set_id
                 AND deleted_at IS NULL
               ORDER BY abbreviation
        LOOP
            str := str || '"' || LOWER(rec.abbreviation) || '_baselined" boolean' || ',';
        END LOOP;
    str := SUBSTRING(str, 0, LENGTH(str));

    EXECUTE 'CREATE EXTENSION IF NOT EXISTS tablefunc;
            DROP TABLE IF EXISTS ' || _table || '_baselined_ct;
            CREATE TEMPORARY TABLE ' || _table || '_baselined_ct AS
            SELECT *
            FROM public.crosstab(''SELECT id, abbreviation, baselined FROM ' || _table || ' order by 1'',
                         ''SELECT abbreviation
                FROM live_data.modules
                WHERE set_id = ' || _set_id || ' AND deleted_at IS NULL
               ORDER BY abbreviation'')
                 AS final_result (' || str || ')';
END
$$;

ALTER FUNCTION sp_mod_baselined_ct(integer, varchar) OWNER TO main;

GRANT EXECUTE ON FUNCTION sp_mod_baselined_ct(integer, varchar) TO chartio;

