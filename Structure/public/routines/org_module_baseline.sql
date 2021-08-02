CREATE OR REPLACE FUNCTION org_module_baseline(org_id integer, mod_id integer)
    RETURNS TABLE
            (
                baselined     boolean,
                baseline_date timestamp WITHOUT TIME ZONE
            )
    LANGUAGE plpgsql
AS
$$
DECLARE
BEGIN
    RETURN QUERY
        SELECT COUNT(ci.id) - COUNT(r.id) = 0 AS baselined,
               MAX(r.created_at)              AS baseline_date
        FROM live_data.criterion_instances ci
                 JOIN live_data.criterion_grade_level cgl ON cgl.criterion_id = ci.criterion_id
                 JOIN live_data.organizations o ON o.id = org_id
            AND cgl.grade_level_id IN (SELECT JSON_ARRAY_ELEMENTS_TEXT(o.grade_level_ids))
                 LEFT JOIN live_data.responses r
                           ON ci.criterion_id = r.criterion_id AND r.first AND r.organization_id = o.id
        WHERE ci.module_id = mod_id
          AND ci.deleted_at IS NULL;

END;
$$;

COMMENT ON FUNCTION org_module_baseline(integer, integer) IS 'Used to check if an org has baselined a module as well as the baseline date';

ALTER FUNCTION org_module_baseline(integer, integer) OWNER TO main;

