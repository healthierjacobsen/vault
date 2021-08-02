CREATE OR REPLACE FUNCTION sp_org_baselined_all(_set_id integer, _table character varying)
    RETURNS TABLE
            (
                org_id            integer,
                baseline_all_date date
            )
    LANGUAGE plpgsql
AS
$$
DECLARE
    rec RECORD;
    str text;
BEGIN

    str := '';
    FOR rec IN SELECT abbreviation
               FROM live_data.modules
               WHERE set_id = _set_id
               ORDER BY abbreviation
        LOOP
            str := str || LOWER(rec.abbreviation) || '_baseline_date,';
        END LOOP;
    str := TRIM(TRAILING ',' FROM str);

    RETURN QUERY EXECUTE 'SELECT
       org_id,
        CASE WHEN baseline IS NOT NULL THEN baseline_date ELSE NULL END as baseline_date
FROM (
    SELECT id AS org_id, ' || str || ',
           DATE(GREATEST(' || str || ')) as baseline_date
    FROM ' || _table || '
         ) as baseline';


END
$$;

ALTER FUNCTION sp_org_baselined_all(integer, varchar) OWNER TO main;

