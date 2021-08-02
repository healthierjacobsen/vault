CREATE OR REPLACE FUNCTION sp_org_assessment_baseline(_org_id integer, _set_id integer)
    RETURNS TABLE
            (
                baselined     boolean,
                baseline_date timestamp WITHOUT TIME ZONE
            )
    LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN QUERY EXECUTE 'SELECT
        COUNT(ci.id) = COUNT(rr.id) as baselined, CASE WHEN COUNT(ci.id) = COUNT(rr.id) THEN MAX(rr.created_at) ELSE null END as baseline_date
FROM live_data.v_criterion_instances ci
JOIN live_data.v_organizations o ON o.id = ' || _org_id || '  AND ci.set_id = ' || _set_id || '
LEFT JOIN live_data.v_criterion_grade_level cgl ON cgl.criterion_id = ci.criterion_id
 AND o.grade_level_ids::jsonb ? cgl.grade_level_id
LEFT JOIN live_data.reporting_responses rr ON rr.organization_id = o.id AND rr.first AND rr.criterion_id = ci.criterion_id';

END
$$;

ALTER FUNCTION sp_org_assessment_baseline(integer, integer) OWNER TO main;

