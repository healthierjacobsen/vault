# Clinton Foundation Metrics

## Queries
    `SELECT * FROM public.cf_summary_data('2020-12-31'::Date);`
    `SELECT * FROM public.ever_enrolled_close_accts_excluded('2020-12-31'::Date);`

**Both queries return the same data points except that the cf_summary_data includes organizations which have been closed.**


## Data Points

- HSP schools reached to date
- HSP students reached to date
- \# of schools serving high-need populations (frl >= 40)
- Percent of schools serving high-need populations (frl >= 40)
- HSP districts reached to date
- HSP districts students reached to date
- \# of districts serving high-need populations (frl >= 40)
- Percent of districts serving high-need populations (frl >= 40)
- HOST sites reached to date
- HOST youth reached to date
- Percent of sites serving high-need populations (frl >= 40)
- Total children impacted (schools + HOST)

## Returns table
    (
        school_count               integer,
        school_student_count       integer,
        school_high_need_count     integer,
        school_high_need_percent   integer,
        district_count             integer,
        district_student_count     integer,
        district_high_need_count   integer,
        district_high_need_percent integer,
        ost_count                  integer,
        ost_youth_count            integer,
        ost_high_need_count        integer,
        ost_high_need_percent      integer,
        total_children_count       integer
    )


### Change History
- [Ticket #2983](https://github.com/alliance/cms/issues/2983)
- [Ticket #3191](https://github.com/alliance/cms/issues/3191)
- [Ticket #3369](https://github.com/alliance/cms/issues/3369)
- [Ticket #3472](https://github.com/alliance/cms/issues/3472)
- [Ticket #3753](https://github.com/alliance/cms/issues/3753))