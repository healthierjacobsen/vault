CREATE OR REPLACE FUNCTION org_last_activity(org_id integer) RETURNS timestamp WITHOUT TIME ZONE
    LANGUAGE plpgsql
AS
$$
DECLARE
    last_activity TIMESTAMP;
BEGIN
    SELECT INTO last_activity MAX(ua.active_at)
    FROM live_data.organization_user ou
             JOIN live_data.user_activities ua ON ua.user_id = ou.user_id
        AND ou.organization_role_id = 200
        AND ou.organization_id = org_id;
    RETURN last_activity;
END;
$$;

COMMENT ON FUNCTION org_last_activity(integer) IS 'Used to retrieve the timestamp of the most recent activity by a team member';

ALTER FUNCTION org_last_activity(integer) OWNER TO main;

GRANT EXECUTE ON FUNCTION org_last_activity(integer) TO chartio;