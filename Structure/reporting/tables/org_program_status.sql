/**
  This table stores the current status of an organizations progress for assessments in a given project.
  Populated by the `reporting.org_program_status` routine
 */

DROP TABLE IF EXISTS reporting.org_program_status;

CREATE TABLE reporting.org_program_status
(
    org_id          integer               NOT NULL,
    program_id      smallint              NOT NULL,
    public          boolean DEFAULT FALSE NOT NULL,
    set_id          integer,
    module_id       integer,
    total_possible  integer               NOT NULL,
    total_responses integer,
    value           varchar(255)
);

ALTER TABLE reporting.org_program_status
    OWNER TO main;

COMMENT ON TABLE reporting.org_program_status IS 'This table stores the current status of an organizations progress for assessments in a given project.';

CREATE INDEX org_program_status_org_id_program_id_index
    ON reporting.org_program_status (org_id, program_id);

GRANT SELECT ON reporting.org_program_status TO sql_analyst;

GRANT SELECT ON reporting.org_program_status TO chartio;

