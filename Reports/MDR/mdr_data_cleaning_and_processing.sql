/**
Verify Data Changes

This verifies if all of the changes in the data_changes table are reflected in the data in the table housing the most recent MDR data set

Output is returned directly (written into the mdr.data_changes table)
*/
-- Approx 1.2s

SELECT *
FROM mdr.verify_data_changes('"Building_M1705066"')
         AS (pid int, mdr_field varchar, our_value varchar, imported_value varchar, verified boolean)
;

/**
Verify Closed and Merged Accounts

This function checks all closing organizations in the provided MDR table to see if there has been program activity in
the past 24 months. If an organization is closing and merging with another organization, then both are checked for activity.

Output is sent to the mdr.close_merge table
*/
--Approx 22.7s

SELECT *
FROM mdr.verify_closed_merged('"Listocr_M1705066"'::varchar)
;

/**
Process and Clean MDR Data Set

This function processes the MDR "Building" and "Listocr" tables and performs the ETL changes (cleans data for import
into CRM).

Output is sent to the mdr.mdr_output and mdr.mdr_ocr_output tables
*/
--Approx 7.8s

SELECT *
FROM mdr.process_mdr_tables('"Building_M1705066"', '"Listocr_M1705066"')
;