CREATE OR REPLACE FUNCTION sp_module_baseline(_set_id integer, _table character varying, _current_date date,
                                              _org_type_id integer) RETURNS void
    LANGUAGE plpgsql
AS
$$
DECLARE
    rec         RECORD;
    str         text;
    before_date date;
    org_graded  boolean;
BEGIN
    RAISE NOTICE 'Starting sp_module_baseline %', _table;
    IF _current_date IS NULL THEN
        before_date = CURRENT_DATE;
    ELSE
        before_date = _current_date;
    END IF;

    SELECT INTO org_graded graded FROM live_data.organization_types WHERE id = _org_type_id;

    -- build temp table of module baselines
    EXECUTE 'DROP TABLE IF EXISTS ' || _table || '_baselines CASCADE';

    EXECUTE 'CREATE TEMPORARY TABLE ' || _table || '_baselines AS
    WITH
     r AS (SELECT organization_id AS org_id,
                                 criterion_id,
                                 created_at
                          FROM (
                                   SELECT r.organization_id,
                                          r.criterion_id,
                                          rv.value,
                                          r.created_at,
                                          ROW_NUMBER()
                                          OVER (PARTITION BY r.organization_id, r.criterion_id ORDER BY r.organization_id, r.criterion_id, r.created_at ASC) AS row_num
                                   FROM live_data.responses r
                                            JOIN live_data.response_values rv ON rv.id = r.response_value_id
                                            JOIN live_data.organizations o ON o.id = r.organization_id
                                   WHERE r.created_at > (SELECT created_at FROM live_data.sets WHERE id = ' ||
            _set_id || ')
                               ) z
                          WHERE row_num = 1
                          UNION
            SELECT o.id AS org_id, r.criterion_id, r.created_at
            FROM live_data.organizations o
                JOIN public.baseline_responses r ON r.organization_id = o.id AND r.created_at < $1
            WHERE r.created_at > (SELECT created_at FROM live_data.sets WHERE id = ' || _set_id || ')
    ),
     ar AS (
        SELECT DISTINCT o.id AS org_id
        FROM live_data.organizations o
            JOIN live_data.responses r ON r.organization_id = o.id
            JOIN live_data.criterion_instances ci
                                    ON ci.criterion_id = r.criterion_id AND ci.deleted_at IS NULL AND ci.set_id = ' ||
            _set_id || '
        WHERE o.deleted_at IS NULL
    )
    SELECT c.org_id AS id, abbreviation, count(c.criterion_id) - count(r.criterion_id) = 0 AS baselined, CASE WHEN count(c.criterion_id) - count(r.criterion_id) = 0 THEN MAX(r.created_at) ELSE NULL END AS baseline_date
    FROM (
              SELECT oc.org_id, ci.criterion_id, s.id AS set_id, m.abbreviation AS abbreviation
              FROM live_data.sets s
                       JOIN live_data.criterion_instances ci
                            ON ci.set_id = s.id AND ci.deleted_at IS NULL AND s.id = ' || _set_id || '
                       JOIN live_data.modules m ON m.id = ci.module_id AND m.deleted_at IS NULL
                       LEFT JOIN live_data.organization_set os ON os.set_id = s.id
                       JOIN (SELECT o.id AS org_id, criterion_id, o.parent_id
                             FROM live_data.organizations o
                                      JOIN live_data.organization_criteria oc ON oc.organization_id = o.id
                             WHERE o.deleted_at IS NULL
                             GROUP BY o.id, oc.criterion_id, o.parent_id
              ) oc ON oc.criterion_id = ci.criterion_id
          ) c
    LEFT JOIN r ON r.org_id = c.org_id AND r.criterion_id = c.criterion_id
    JOIN ar ON ar.org_id = c.org_id
    GROUP BY c.org_id, abbreviation
    ORDER BY c.org_id, abbreviation' USING before_date;

    --     IF org_graded THEN
--         EXECUTE 'CREATE TEMPORARY TABLE '|| _table ||'_baselines AS
--         WITH r AS (SELECT o.id AS org_id, r.criterion_id, r.created_at
--     FROM live_data.organizations o
--     JOIN live_data.responses r ON r.organization_id = o.id AND r.latest
--     JOIN live_data.response_values rv ON rv.id = r.response_value_id
--     WHERE r.created_at < $1
-- )
--      SELECT ct.organization_id as id, m.abbreviation, count(ci.criterion_id)-count(r.criterion_id)=0 AS baselined, CASE WHEN count(ci.criterion_id)-count(r.criterion_id)=0 THEN max(r.created_at) ELSE NULL END AS baseline_date
-- FROM (SELECT *
--            --FROM (
--            --       SELECT *,
--            --              ROW_NUMBER() OVER ( PARTITION BY organization_id
--            --                ORDER BY organization_id ) AS row_num
--                   FROM '||_table||'
--            --     ) AS s1
--            --WHERE s1.row_num = 1
--                 ) ct
--         JOIN live_data.organization_criteria oc ON oc.organization_id = ct.organization_id
--         JOIN live_data.criterion_instances ci ON ci.criterion_id = oc.criterion_id AND ci.set_id = '||_set_id||' AND ci.deleted_at IS NULL
--         JOIN live_data.modules m ON m.id = ci.module_id AND m.set_id = '||_set_id||' AND m.deleted_at IS NULL
--         LEFT JOIN r ON r.criterion_id = ci.criterion_id AND r.org_id = ct.organization_id
--         --LEFT JOIN live_data.responses r ON ci.criterion_id = r.criterion_id AND r.organization_id = ct.organization_id AND r.created_at < $1 AND r.first
--         GROUP BY ct.organization_id, m.abbreviation
--         ORDER BY ct.organization_id, m.abbreviation'
--             USING before_date;
--     ELSE
--         EXECUTE 'CREATE TEMPORARY TABLE '|| _table ||'_baselines AS
--         WITH r AS (SELECT o.id AS org_id, r.criterion_id, r.created_at
--                    FROM live_data.organizations o
--                             JOIN live_data.responses r ON r.organization_id = o.id AND r.latest
--                             JOIN live_data.response_values rv ON rv.id = r.response_value_id
--                    WHERE r.created_at < $1
--         )
--      SELECT ct.organization_id as id, m.abbreviation, count(ci.criterion_id)-count(r.criterion_id)=0 AS baselined, CASE WHEN count(ci.criterion_id)-count(r.criterion_id)=0 THEN max(r.created_at) ELSE NULL END AS baseline_date
-- FROM (SELECT *
--            --FROM (
--            --       SELECT *,
--            --              ROW_NUMBER() OVER ( PARTITION BY organization_id
--            --                ORDER BY organization_id ) AS row_num
--                   FROM '||_table||'
--            --     ) AS s1
--            --WHERE s1.row_num = 1
--                 ) ct
--         JOIN live_data.criterion_instances ci ON ci.set_id = '||_set_id||' AND ci.deleted_at IS NULL
--         JOIN live_data.modules m ON m.id = ci.module_id AND m.set_id = '||_set_id||' AND m.deleted_at IS NULL
--         LEFT JOIN r ON r.criterion_id = ci.criterion_id AND r.org_id = ct.organization_id
--         --LEFT JOIN live_data.responses r ON ci.criterion_id = r.criterion_id AND r.organization_id = ct.organization_id AND r.created_at < $1 AND r.first
--         GROUP BY ct.organization_id, m.abbreviation
--         ORDER BY ct.organization_id, m.abbreviation'
--             USING before_date;
--     END IF;

    --     CREATE INDEX temp_module_baselines_id_index ON _table ||'_baselines'(id);

    -- run crosstab function
    PERFORM public.sp_mod_baselined_ct(_set_id, _table || '_baselines');

    -- run crosstab function
    PERFORM public.sp_mod_baseline_date_ct(_set_id, _table || '_baselines');

    -- build out the columns for the join
    str := 'b.id, ';
    FOR rec IN SELECT abbreviation
               FROM live_data.modules
               WHERE set_id = _set_id
                 AND deleted_at IS NULL
               ORDER BY abbreviation
        LOOP
            str := str || LOWER(rec.abbreviation) || '_baselined, ' || LOWER(rec.abbreviation) || '_baseline_date,';
        END LOOP;
    str := TRIM(TRAILING ',' FROM str);
    -- execute join into final temp table
    RAISE NOTICE 'Creating final crosstab table %_mod_baselines_ct', _table;
    EXECUTE 'DROP TABLE IF EXISTS ' || _table || '_mod_baselines_ct;
     CREATE TEMPORARY TABLE ' || _table || '_mod_baselines_ct AS
         SELECT ' || str || ' FROM ' || _table || '_baselines' || '_baselined_ct b JOIN ' || _table || '_baselines' ||
            '_baseline_date_ct d ON b.id = d.id';
    RAISE NOTICE 'Completed sp_module_baseline %', _table;
END
$$;

ALTER FUNCTION sp_module_baseline(integer, varchar, date, integer) OWNER TO main;

