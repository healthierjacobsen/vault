/**
  This table stores the relationship of a P2 program to a CRM program
  The population of this table is completely manual
  The p2_program_id column keys to the live_data.programs.id column
 */

DROP TABLE IF EXISTS crm.ahg_program;

CREATE TABLE crm.ahg_program
(
    p2_program_id integer NOT NULL,
    ahg_program   varchar NOT NULL
);

ALTER TABLE crm.ahg_program
    OWNER TO main;

COMMENT ON TABLE crm.ahg_program IS 'This table stores the relationship of a P2 program to a CRM program';

CREATE INDEX ahg_program_p2_program_id_index
    ON crm.ahg_program (p2_program_id);

GRANT DELETE, INSERT, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON crm.ahg_program TO sql_analyst;

GRANT SELECT ON crm.ahg_program TO chartio;

