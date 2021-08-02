CREATE OR REPLACE FUNCTION org_program_status(_program integer, _organization integer) RETURNS void
    LANGUAGE plpgsql
AS
$$
BEGIN
    -- default the queries to use live_data schema unless specified
    SET search_path TO live_data,public;

    -- clear previous entries
    DELETE FROM reporting.org_program_status WHERE org_id = _organization AND program_id = _program;

    -- recalculate new entries
    INSERT INTO reporting.org_program_status (org_id, program_id, public, set_id, module_id, total_possible,
                                              total_responses, value)
    WITH c AS (
        SELECT oc.organization_id AS org_id,
               s.program_id       AS prog_id,
               s.public,
               ci.set_id,
               ci.module_id,
               oc.criterion_id
        FROM organization_criteria oc
                 JOIN criterion_instances ci ON ci.criterion_id = oc.criterion_id
                 JOIN sets s ON s.id = ci.set_id
                 JOIN modules m ON m.id = ci.module_id
        WHERE oc.organization_id = _organization
          AND s.program_id = _program
          AND ci.deleted_at IS NULL
          AND m.deleted_at IS NULL
--            ci.criterion_id
--     FROM sets s
--              JOIN criterion_instances ci ON ci.set_id = s.id AND ci.deleted_at IS NULL AND s.program_id = _program
--              JOIN modules m ON m.id = ci.module_id AND m.deleted_at IS NULL
--              JOIN organization_criteria oc ON oc.criterion_id = ci.criterion_id AND oc.organization_id = _organization
--     WHERE ci.deleted_at IS NULL
    )
    SELECT possible.org_id,
           possible.prog_id,
           TRUE,--possible.public,
           possible.set_id,
           possible.module_id,
           possible.total_possible,
           responseStats.total_responses,
           responseStats.value
    FROM (SELECT c.set_id, c.module_id, COUNT(DISTINCT r.id) AS total_responses, rv.value
          FROM c
                   JOIN responses r ON r.criterion_id = c.criterion_id AND r.latest
                   JOIN response_values rv ON rv.id = r.response_value_id
          WHERE r.organization_id = _organization
          GROUP BY GROUPING SETS ( (),
              (c.set_id),
              (c.set_id, c.module_id),
              (c.set_id, rv.value),
              (c.set_id, c.module_id, rv.value),
              (rv.value))) responseStats
             RIGHT JOIN
         (SELECT c.org_id,
                 c.prog_id,
                 c.public,
                 c.set_id,
                 c.module_id,
                 COUNT(DISTINCT c.criterion_id) AS total_possible
          FROM c
                   JOIN organizations o ON o.id = _organization
                   LEFT JOIN sets s ON s.id = c.set_id
          WHERE s.organization_type_id = o.organization_type_id
             OR c.set_id IS NULL
          GROUP BY GROUPING SETS ((c.org_id, c.prog_id, c.public),
                                  (c.org_id, c.prog_id, c.public, c.set_id, c.module_id),
                                  (c.org_id, c.prog_id, c.public, c.set_id) )) possible
         ON (responseStats.set_id = possible.set_id AND responseStats.module_id = possible.module_id)
             OR
            (responseStats.set_id IS NULL AND possible.set_id IS NULL AND responseStats.module_id = possible.module_id)
             OR
            (responseStats.module_id IS NULL AND possible.module_id IS NULL AND responseStats.set_id = possible.set_id)
             OR
            (responseStats.set_id IS NULL AND possible.set_id IS NULL AND responseStats.module_id IS NULL AND
             possible.module_id IS NULL);
END
$$;

ALTER FUNCTION org_program_status(integer, integer) OWNER TO main;

