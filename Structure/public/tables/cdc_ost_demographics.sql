
DROP TABLE IF EXISTS public.cdc_ost_demographics;

create table public.cdc_ost_demographics
(
	"p2OrgID" integer not null
		constraint cdc_ost_demographics_pk
			primary key,
	before_after text,
	school_grounds text
);

alter table public.cdc_ost_demographics owner to main;

grant delete, insert, references, select, trigger, truncate, update on public.cdc_ost_demographics to sql_analyst;

grant delete, insert, references, select, trigger, truncate, update on public.cdc_ost_demographics to chartio;

