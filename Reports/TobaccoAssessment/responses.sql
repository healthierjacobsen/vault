--Tobacco Assessment Baseline Responses

SELECT br.*, brv.*
FROM public.baseline_responses br
         JOIN live_data.response_values brv ON br.response_value_id = brv.id
         JOIN live_data.criterion_instances ci ON ci.criterion_id = br.criterion_id
         JOIN live_data.sets s ON s.id = ci.set_id
         JOIN live_data.organizations o ON o.id = br.organization_id
WHERE s.program_id = 6000
  AND s.organization_type_id = 200
  AND o.deleted_at IS NULL
  AND o.is_demo IS FALSE
  AND br.created_at <= '2021-04-27'
;

--Tobacco Assessment Latest (current) Responses

SELECT r.*, rv.*
FROM live_data.responses r
         JOIN live_data.response_values rv ON r.response_value_id = rv.id
         JOIN live_data.criterion_instances ci ON ci.criterion_id = r.criterion_id
         JOIN live_data.sets s ON s.id = ci.set_id
         JOIN live_data.organizations o ON o.id = r.organization_id
WHERE r.id IN (
    (SELECT id
     FROM (SELECT id,
                  ROW_NUMBER() OVER
                      (PARTITION BY organization_id, criterion_id ORDER BY id DESC) AS rnum
           FROM live_data.responses
           WHERE created_at <= '2021-04-27') t
     WHERE t.rnum = 1)
)
  AND s.program_id = 6000
  AND s.organization_type_id = 200
  AND o.deleted_at IS NULL
  AND o.is_demo IS FALSE
;