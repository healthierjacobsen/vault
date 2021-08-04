
DROP MATERIALIZED VIEW IF EXISTS baseline_responses;

CREATE MATERIALIZED VIEW baseline_responses AS
WITH first AS (
    SELECT r.organization_id,
           r.criterion_id,
           r.created_at
    FROM live_data.responses r
    WHERE r.first
      AND r.deleted_at IS NULL
)
SELECT z.id,
       z.criterion_id,
       z.organization_id,
       z.user_id,
       z.active_program_id,
       z.active_set_id,
       z.active_module_id,
       z.criterion_variant_id,
       z.created_at,
       z.updated_at,
       z.deleted_at,
       z.latest,
       z.first,
       z.response_value_id,
       z.baseline
FROM (SELECT DISTINCT b.id,
                      b.criterion_id,
                      b.organization_id,
                      b.user_id,
                      b.active_program_id,
                      b.active_set_id,
                      b.active_module_id,
                      b.criterion_variant_id,
                      b.created_at,
                      b.updated_at,
                      b.deleted_at,
                      b.latest,
                      b.first,
                      b.response_value_id,
                      MAX(b.created_at)
                      OVER (PARTITION BY b.organization_id, b.criterion_id ORDER BY b.organization_id, b.criterion_id, b.created_at DESC) AS baseline
      FROM (SELECT r.id,
                   r.criterion_id,
                   r.organization_id,
                   r.user_id,
                   r.active_program_id,
                   r.active_set_id,
                   r.active_module_id,
                   r.criterion_variant_id,
                   r.created_at,
                   r.updated_at,
                   r.deleted_at,
                   r.latest,
                   r.first,
                   r.response_value_id
            FROM live_data.responses r
                     JOIN first f ON f.organization_id = r.organization_id AND f.criterion_id = r.criterion_id AND
                                     r.created_at < (f.created_at + '48:00:00'::interval) AND r.deleted_at IS NULL
            WHERE (f.created_at + '48:00:00'::interval) > r.created_at) b) z
WHERE z.created_at = z.baseline
ORDER BY z.baseline DESC;

ALTER MATERIALIZED VIEW baseline_responses OWNER TO main;

CREATE UNIQUE INDEX baseline_responses_idx
    ON baseline_responses (organization_id, criterion_id);

GRANT DELETE, INSERT, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON baseline_responses TO sql_analyst;

GRANT SELECT ON baseline_responses TO chartio;

