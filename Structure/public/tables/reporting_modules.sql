CREATE TABLE reporting_modules
(
    id               serial
        CONSTRAINT reporting_modules_pk
            PRIMARY KEY,
    module           varchar NOT NULL,
    criterion_handle varchar NOT NULL
);

ALTER TABLE reporting_modules
    OWNER TO main;

GRANT DELETE, INSERT, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON reporting_modules TO sql_analyst;

GRANT DELETE, INSERT, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON reporting_modules TO chartio;

