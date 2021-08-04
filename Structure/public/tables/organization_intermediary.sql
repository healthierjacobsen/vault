
DROP TABLE IF EXISTS public.organization_intermediary;

CREATE TABLE public.organization_intermediary
(
    organization_id integer NOT NULL
        CONSTRAINT organization_intermediary_pk
            PRIMARY KEY,
    intermediary_id integer NOT NULL
);

ALTER TABLE public.organization_intermediary
    OWNER TO main;

GRANT DELETE, INSERT, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON public.organization_intermediary TO sql_analyst;

GRANT DELETE, INSERT, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON public.organization_intermediary TO chartio;

