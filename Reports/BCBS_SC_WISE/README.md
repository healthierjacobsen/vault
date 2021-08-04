# BCBS SC WISE

## Queries
    `SELECT * FROM public.sp_bcbs('2020-08-01', '2021-01-31');`


## Data Points

- \# of schools associated with the grant
- \# of grant schools working on the assessment
- % of grant schools working on the assessment
  - Denominator is all schools in the grant 
- \# of grant schools that have completed the assessment
- % of grant schools that have completed the assessment
  - denominator is all schools in the grant that had not yet completed the assessment at the beginning of the specified reporting period
- \# of schools starting or updating an AP
- % of schools starting or updating an AP
  - denominator is all schools in the grant
- \# of schools that have improved any of the PE/PA assessment items
- % of schools that have improved any of the PE/PA assessment items
  - denominator is all schools in the grant able to make an improvement for at least one of the PA items
- \# of schools that have improved any of the Nutrition assessment items
- % of schools that have improved any of the Nutrition assessment items
  - denominator is all schools in the grant able to make an improvement for at least one of the Nutrition items
- \# of schools that have grown the size of their team and/or improved or are fully meeting PO-01
o % of schools that have grown the size of their team and/or improved or are fully meeting PO-01
  - denominator is all schools in the grant
- \# of schools that have improved or are fully meeting PO-01
- % of schools that have improved or are fully meeting PO-01
  - denominator is all schools in the grant
- \# of schools that have grown the size of their team
- % of schools that have grown the size of their team
  - denominator is all schools in the grant
- Average # of Team Members for supported schools (total team members for all schools in the grant / all schools in the grant)
- \# of schools that have improved any of the EW assessment items
- % of schools that have improved any of the EW assessment items
  - denominator is all schools in the grant able to make an improvement for at least one of the PA items

## Returns table
    (
        total_schools              integer,
        num_assessment_schools     integer,
        per_assessment_schools     double precision,
        num_completed              integer,
        per_completed              double precision,
        num_action_plan            integer,
        per_action_plan            double precision,
        num_improved_pepa          integer,
        num_available_pepa         integer,
        num_improved_nu            integer,
        num_available_nu           integer,
        num_grown_or_po_1          integer,
        per_grown_or_po_1          double precision,
        num_improved_or_fully_po_1 integer,
        per_improved_or_fully_po_1 double precision,
        num_improved_or_fully_po_3 integer,
        per_improved_or_fully_po_3 double precision,
        num_grown                  integer,
        per_grown                  double precision,
        avg_team                   double precision,
        num_improved_ew            integer,
        per_improved_ew            double precision
    )


### Change History
- [Ticket #3098](https://github.com/alliance/cms/issues/3098)
- [Ticket #3430](https://github.com/alliance/cms/issues/3430)



## Relies On
- `public.sp_latest_responses`
- `public.sp_baseline_responses`