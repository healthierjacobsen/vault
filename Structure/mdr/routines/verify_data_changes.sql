CREATE OR REPLACE FUNCTION verify_data_changes(_building_table character varying) RETURNS SETOF record
    LANGUAGE plpgsql
AS
$$
DECLARE
    change_rec RECORD;
    return_rec RECORD;
    check_val  varchar;
    verified   BOOLEAN;
BEGIN

    /**
      This function verifies if all of the changes in the data_changes table are made in the provided MDR table

      Output is returned directly

      SELECT * FROM mdr.verify_data_changes('"Building_M1705066"'::varchar) AS (pid int, mdr_field varchar, our_value varchar, imported_value varchar, verified boolean);

    */


    SET SEARCH_PATH TO mdr;

    FOR change_rec IN SELECT * FROM mdr.data_changes WHERE verified_at IS NULL AND mdr_field IS NOT NULL
        LOOP
            EXECUTE FORMAT('SELECT "' || change_rec.mdr_field || '" FROM ' || _building_table || ' WHERE pid::int = $1')
                USING change_rec.organization_pid
                INTO check_val;

            IF check_val ~ '^[0-9\.]+$' THEN
                check_val := check_val::decimal;
            END IF;

            IF (LOWER(check_val) = LOWER(change_rec.new_value)) THEN
                verified := TRUE;
            ELSE
                verified := FALSE;
            END IF;
            return_rec :=
                    (change_rec.organization_pid, change_rec.mdr_field, change_rec.new_value, check_val, verified);
            RETURN NEXT return_rec;
        END LOOP;
END;
$$;

ALTER FUNCTION verify_data_changes(varchar) OWNER TO main;

GRANT EXECUTE ON FUNCTION verify_data_changes(varchar) TO sql_analyst;

