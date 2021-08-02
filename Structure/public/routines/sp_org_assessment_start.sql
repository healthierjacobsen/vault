CREATE OR REPLACE FUNCTION sp_org_assessment_start(_set_id integer)
    RETURNS TABLE
            (
                org_id     integer,
                start_date date
            )
    LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN QUERY EXECUTE 'SELECT
        o.id, MIN(rr.created_at)::date AS start_date
FROM live_data.v_criterion_instances ci
         JOIN live_data.v_sets s ON s.id = ' || _set_id || ' AND ci.set_id = s.id AND ci.deleted_at IS NULL
         JOIN live_data.v_organization_types ot ON ot.id = s.organization_type_id
         JOIN live_data.v_organizations o ON o.organization_type_id = s.organization_type_id AND o.deleted_at IS NULL AND is_demo = false
         LEFT JOIN live_data.v_criterion_grade_level cgl ON cgl.criterion_id = ci.criterion_id
                AND o.grade_level_ids::jsonb ? cgl.grade_level_id
         LEFT JOIN live_data.reporting_responses rr ON rr.organization_id = o.id AND rr.first AND rr.criterion_id = CASE WHEN ot.graded THEN cgl.criterion_id ELSE ci.criterion_id END
GROUP BY o.id';

END
$$;

ALTER FUNCTION sp_org_assessment_start(integer) OWNER TO main;

