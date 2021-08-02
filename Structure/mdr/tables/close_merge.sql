CREATE TABLE mdr.close_merge
(
    id                         integer,
    pid                        varchar               NOT NULL,
    status                     text,
    reason                     text,
    assessment_activity        boolean DEFAULT FALSE,
    plan_activity              boolean DEFAULT FALSE,
    engagement_record          boolean DEFAULT FALSE,
    merged_assessment_activity boolean DEFAULT FALSE,
    merged_plan_activity       boolean DEFAULT FALSE,
    merged_engagement_record   boolean DEFAULT FALSE,
    check_needed               boolean DEFAULT FALSE NOT NULL
);

ALTER TABLE mdr.close_merge
    OWNER TO sql_analyst;

GRANT SELECT ON mdr.close_merge TO chartio;

