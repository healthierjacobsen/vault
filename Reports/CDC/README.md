# CDC

## Queries
    `SELECT * FROM public.sp_cdc_nutrition('2019-06-01', '2020-05-31');`
    `SELECT * FROM public.sp_cdc_ost('2019-06-01', '2020-05-31');`


## Data Points

- \# of school districts or schools accessing a resource
- \# of schools responding with or updating a response to fully meeting (3) on 1+ Nutrition Topic criteria

## Returns table
    (
        resource_orgs integer, 
        nutrition_fully_meeting integer
    )
    (
        resource_accesses_before_after integer, 
        resource_accesses_school_based integer, 
        po_10_fully integer
    )

### Change History
- [Ticket #3109](https://github.com/alliance/cms/issues/3109)
- [Ticket #3110](https://github.com/alliance/cms/issues/3110)