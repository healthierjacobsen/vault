# MDR schema

This schema is mainly used as a location for data processing of our data feed files from MDR


## Routines

- `process_mdr_tables` - This function processes the MDR "Building" and "Listocr" tables and performs the ETL changes (cleans data for import
into CRM) and generates output to the `mdr_output` table.
- `verify_closed_merged` - This function checks all closing organizations in the provided MDR table to see if there has been program activity in
the past 24 months. If an organization is closing and merging with another organization, then both are checked for activity.
- `verify_data_changes` - This verifies if all of the changes in the data_changes table are reflected in the data in the table housing the most recent MDR data set


## Tables

- `close_merge` - This table is populated by the `verify_closed_merged` routine.
- `data_changes` - This table is our internally maintained record of data changes and includes when those changes were implemented by MDR.
- `data_changes_closures` - Similar to the `data_changes` table except these are specifically for an organization closure.
- `dma_import` - This houses the Designated Market Area codes used by the `process_mdr_tables` routine.