CREATE OR REPLACE FUNCTION sp_cdc_ost(_start_date date, _end_date date)
    RETURNS TABLE
            (
                resource_accesses_before_after integer,
                resource_accesses_school_based integer,
                po_10_fully                    integer
            )
    LANGUAGE plpgsql
AS
$$
DECLARE
    po_10                          int;
    resource_accesses_before_after int;
    resource_accesses_school_based int;
BEGIN

    SELECT INTO resource_accesses_before_after COUNT(DISTINCT o.id)
    FROM (SELECT ral.user_id
          FROM live_data.resource_access_logs ral
          WHERE ral.logged_at BETWEEN _start_date AND _end_date
            AND ral.access_type_id IN (2, 3)
            AND ral.user_id IS NOT NULL
          UNION
          SELECT ua.user_id
          FROM live_data.user_activities ua
          WHERE ua.active_at BETWEEN _start_date AND _end_date
            AND ua.activity ILIKE '%/resources/%'
         ) AS uu
             JOIN live_data.users u ON u.id = uu.user_id AND u.email NOT LIKE '%@healthiergeneration.org%'
             JOIN live_data.organization_user ou ON ou.user_id = u.id AND ou.access_approved_at IS NOT NULL
             JOIN live_data.organizations o ON o.id = ou.organization_id AND o.is_demo IS FALSE
             JOIN public.cdc_ost_demographics cod ON cod."p2OrgID" = o.id
    WHERE o.deleted_at IS NULL
      AND u.deleted_at IS NULL
      AND LOWER(cod.before_after) = 'yes';


    SELECT INTO resource_accesses_school_based COUNT(DISTINCT o.id)
    FROM (SELECT ral.user_id
          FROM live_data.resource_access_logs ral
          WHERE ral.logged_at BETWEEN _start_date AND _end_date
            AND ral.access_type_id IN (2, 3)
            AND ral.user_id IS NOT NULL
          UNION
          SELECT ua.user_id
          FROM live_data.user_activities ua
          WHERE ua.active_at BETWEEN _start_date AND _end_date
            AND ua.activity ILIKE '%/resources/%'
         ) AS uu
             JOIN live_data.users u ON u.id = uu.user_id AND u.email NOT LIKE '%@healthiergeneration.org%'
             JOIN live_data.organization_user ou ON ou.user_id = u.id AND ou.access_approved_at IS NOT NULL
             JOIN live_data.organizations o ON o.id = ou.organization_id AND o.is_demo IS FALSE
             JOIN public.cdc_ost_demographics cod ON cod."p2OrgID" = o.id
    WHERE o.deleted_at IS NULL
      AND u.deleted_at IS NULL
      AND LOWER(cod.school_grounds) = 'yes';


    DROP TABLE IF EXISTS po_10_fully;
    CREATE TEMP TABLE po_10_fully AS
    SELECT r.organization_id
    FROM live_data.responses r
             JOIN live_data.response_values rv ON r.response_value_id = rv.id AND rv.alignment = 1
             JOIN live_data.criterion_instances ci ON ci.criterion_id = r.criterion_id AND ci.handle = 'PO-10'
    WHERE r.created_at BETWEEN _start_date AND _end_date;


    SELECT INTO po_10 COUNT(DISTINCT o.id)
    FROM live_data.organizations o
             JOIN po_10_fully pf ON pf.organization_id = o.id
             JOIN public.cdc_ost_demographics cod ON cod."p2OrgID" = o.id
    WHERE o.deleted_at IS NULL
      AND o.is_demo = FALSE
      AND o.organization_type_id = 100
      AND LOWER(cod.before_after) = 'yes';

    RETURN QUERY SELECT resource_accesses_before_after, resource_accesses_school_based, po_10;
END
$$;

ALTER FUNCTION sp_cdc_ost(date, date) OWNER TO main;

