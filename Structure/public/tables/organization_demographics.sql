
DROP TABLE IF EXISTS public.organization_demographics;

CREATE TABLE public.organization_demographics
(
    organization_id          integer               NOT NULL
        CONSTRAINT organization_demographics_pk
            PRIMARY KEY,
    minority_percent         integer,
    african_american_percent integer,
    asian_percent            integer,
    caucasian_percent        integer,
    hispanic_percent         integer,
    native_american_percent  integer,
    frl_percent              integer,
    is_title_1               boolean,
    is_majority_minority     boolean DEFAULT FALSE NOT NULL,
    is_on_school_grounds     boolean,
    is_during_summer         boolean,
    is_before_after_program  boolean,
    school_year_enrollment   integer
);

ALTER TABLE public.organization_demographics
    OWNER TO main;

GRANT DELETE, INSERT, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON public.organization_demographics TO sql_analyst;

GRANT DELETE, INSERT, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON public.organization_demographics TO chartio;

