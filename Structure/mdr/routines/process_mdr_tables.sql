CREATE OR REPLACE FUNCTION process_mdr_tables(_building_table character varying, _listocr_table character varying) RETURNS character varying
    LANGUAGE plpgsql
AS
$$
DECLARE
    change_rec      RECORD;
    check_val       varchar;
    verified_change INTEGER;
BEGIN

    /**
      This function processes the MDR "Building" and "Listocr" tables and performs the ETL changes.

      Output is sent to the mdr.mdr_output and mdr.mdr_ocr_output tables

      SELECT * FROM mdr.process_mdr_tables('"Building_M1705066"', '"Listocr_M1705066"')

     */


    /*
     Dont overwrite frl, enrollment, or ethnicity fields with null
     */


    /*
    Create temporary table that excludes institutions in Canada and Library and colleges and daycare
     and institutions which are solely adult education
     */
    DROP TABLE IF EXISTS temp_mdr_building;
    EXECUTE 'CREATE TABLE temp_mdr_building AS SELECT filetype, pid, parentpid, upid, nceshid, inst, mstreet, mcity, mstate, mzipcode, mzipext, zipmetro, areacode, exchange, number, pstreet, pcity, pstate, pzipcode, enrollment, numschools, lowgrade, highgrade, schtype, perwhite, perblack, perindian, perasian, perhisp, cteched, adulted, speced, charter, magnet, beforeaft, totstndts, lunchprgm, cnty_name, dma, geo_lat, geo_long, stu_need_per, pzipext, cmo_pid  FROM mdr.' ||
            _building_table || ' WHERE filetype IN (1,2,3,4,5,7,9,10,13,14,15,36) AND adulted != ''*''';

    /*
     Create temporary table from the MDR ListOCR file table
     */
    DROP TABLE IF EXISTS temp_mdr_list_ocr;
    EXECUTE 'CREATE TABLE temp_mdr_list_ocr AS SELECT *  FROM mdr.' ||
            _listocr_table;

    /*
     Apply our HG specific overrides to the data
     */
    FOR change_rec IN SELECT * FROM mdr.data_changes WHERE verified_at IS NULL AND mdr_field IS NOT NULL
        LOOP
            EXECUTE FORMAT('SELECT "' || change_rec.mdr_field || '" FROM temp_mdr_building WHERE pid::int = $1')
                USING change_rec.organization_pid::int
                INTO check_val;

            IF check_val ~ '^[0-9\.]+$' THEN
                check_val := check_val::decimal;
            END IF;

            IF (LOWER(check_val) = LOWER(change_rec.new_value)) THEN
                EXECUTE FORMAT('UPDATE data_changes SET verified_at = NOW() WHERE id = $1') USING change_rec.id;
            ELSE
                EXECUTE FORMAT('UPDATE temp_mdr_building SET %s = $1 WHERE pid::int = $2',
                               QUOTE_IDENT(change_rec.mdr_field)) USING change_rec.new_value::varchar, change_rec.organization_pid;
            END IF;
        END LOOP;

    /*
     Build the output table that will be used to import to CRM
     */
    DROP TABLE IF EXISTS mdr_output;
    CREATE TABLE mdr_output AS
    SELECT m.ava_institutiontype_displayname,
           m.ava_stakeholdertype,
           pid           AS ava_pidnumber,
           ava_parentpid,
           CASE
               WHEN m.nceshid NOTNULL AND m.nceshid != '' AND m.ava_stakeholdertype = 'School'
                   THEN LPAD(m.nceshid, 12, '0')
               WHEN m.nceshid NOTNULL AND m.nceshid != '' AND
                    m.ava_stakeholdertype IN ('District', 'Charter Management Organization')
                   THEN LPAD(m.nceshid, 7, '0')
               ELSE NULL
               END       AS ava_ncesid,
           inst          AS ava_accountname,
           mstreet       AS ava_address1_line1,
           mcity         AS ava_cityaddress1_city,
           mstate        AS ava_state,
           ava_county_ava_state,
           ava_address1_postalcode,
           ava_locale,
           ava_telephone1,
           pstreet       AS ava_address2_line1,
           pcity         AS ava_address2_city,
           pstate        AS ava_address2stateidname,
           ava_address2_postalcode::text,
           enrollment    AS new_schoolyearenrollment,
           numschools    AS ava_numberofschoolsindistrict,
           m.ava_lowgrade,
           m.ava_highgrade,
           ava_schoollevel,
           perasian_int  AS ava_asianpercent,
           perindian_int AS ava_amindianpercent,
           perblack_int  AS ava_blackpercent,
           perwhite_int  AS ava_whitepercent,
           perhisp_int   AS ava_hispanicpercent,
           CASE -- when all demographics are nulls then null else calculate
               WHEN perasian_int IS NULL AND perblack_int IS NULL AND perindian_int IS NULL AND perhisp_int IS NULL AND
                    perwhite_int IS NULL THEN
                   NULL
               ELSE (COALESCE(perasian_int::int, 0) + COALESCE(perblack_int::int, 0) + COALESCE(perindian_int::int, 0) +
                     COALESCE(perhisp_int::int, 0))
               END
                         AS ahg_minoritypercent,
           GREATEST(perasian_int, perblack_int, perindian_int,
                    perhisp_int, perwhite_int)
                         AS per_greatest,
           CASE
               WHEN GREATEST(perasian_int, perblack_int, perindian_int, perhisp_int, perwhite_int) > 0
                   THEN
                   CASE
                       WHEN
                               perindian_int =
                               GREATEST(perasian_int, perblack_int, perindian_int, perhisp_int, perwhite_int)
                           THEN 'Native American'
                       WHEN
                               perasian_int = GREATEST(perasian_int, perblack_int, perindian_int,
                                                       perhisp_int, perwhite_int)
                           THEN 'Asian'
                       WHEN
                               perblack_int = GREATEST(perasian_int, perblack_int, perindian_int,
                                                       perhisp_int, perwhite_int)
                           THEN 'African American'
                       WHEN
                               perhisp_int = GREATEST(perasian_int, perblack_int, perindian_int,
                                                      perhisp_int, perwhite_int)
                           THEN 'Hispanic'
                       WHEN
                               perwhite_int = GREATEST(perasian_int, perblack_int, perindian_int,
                                                       perhisp_int, perwhite_int)
                           THEN 'Caucasian'
                       ELSE NULL
                       END
               ELSE NULL
               END       AS ahg_primaryethnicity,
           ava_cteched,
           ava_charter,
           ava_magnet,
           ava_beforeafterprograms,
           totstndts     AS ava_totalenrollment,
           lunchprgm     AS ava_frlnumber,
           dma_name      AS ava_designatedmarketingarea,
           ava_dateschoolopened,
           geo_lat       AS ava_address1_lat,
           geo_long      AS ava_address1_long,
           stu_need_per  AS ava_frlpercent,
           ava_title1
    FROM (
             SELECT
                 -- fields that are taken directly from MDR file
                 b.pid,
                 b.nceshid::text,
                 b.inst,
                 b.mstreet,
                 b.mcity,
                 b.mstate,
                 b.pstreet,
                 b.pcity,
                 b.pstate,
                 -- dont override enrollment with null if there is already data
                 CASE
                     WHEN (NULLIF(b.enrollment, '') IS NULL AND od.school_year_enrollment IS NOT NULL)
                         THEN od.school_year_enrollment
                     ELSE NULLIF(b.enrollment, '')::INTEGER END AS enrollment,
                 b.numschools,
                 NULLIF(b.perwhite, '')::INTEGER,
                 NULLIF(b.perblack, '')::INTEGER,
                 NULLIF(b.perindian, '')::INTEGER,
                 NULLIF(b.perasian, '')::INTEGER,
                 NULLIF(b.perhisp, '')::INTEGER,
                 b.totstndts,
                 b.lunchprgm,
                 b.geo_lat,
                 b.geo_long,
                 -- fields that get manipulated
                 b.filetype,
                 parentpid::TEXT,
                 zipmetro,
                 lowgrade,
                 highgrade,
                 schtype,
                 cteched,
                 charter,
                 magnet,
                 beforeaft,
                 -- fields used to calculate other fields and discarded
                 upid::text,
                 cmo_pid::text,
                 cnty_name,
                 mzipcode::text,
                 mzipext::text,
                 areacode::text,
                 exchange::text,
                 number::text,
                 pzipcode::text,
                 pzipext::text,
                 dma,
                 speced,
                 -- dont override frl with null if there is already data
                 CASE
                     WHEN (NULLIF(stu_need_per, '') IS NULL AND od.frl_percent IS NOT NULL) THEN od.frl_percent
                     ELSE NULLIF(stu_need_per, '')::INTEGER END AS stu_need_per,
                 dma_name,
                 CASE
                     WHEN POSITION('-' IN b.cnty_name) > 0
                         THEN CONCAT(REPLACE(REPLACE(b.cnty_name, '-', ''), ' ', ''), '_', mstate)
                     ELSE
                         CONCAT(REPLACE(b.cnty_name, ' ', ''), '_', mstate)
                     END                                        AS ava_county_ava_state,
                 -- cleaning parentpid
                 CASE
                     WHEN NULLIF(b.cmo_pid::text, '') IS NOT NULL THEN b.cmo_pid::text
                     WHEN NULLIF(b.cmo_pid::text, '') IS NULL AND NULLIF(b.upid::text, '') IS NOT NULL THEN b.upid
                     WHEN NULLIF(b.cmo_pid::text, '') IS NULL AND NULLIF(b.upid::text, '') IS NULL
                         AND NULLIF(b.parentpid::TEXT, '') IS NULL THEN '1111111'
                     ELSE b.parentpid::TEXT
                     END                                        AS ava_parentpid,
                 -- cleaning institution type
                 CASE
                     WHEN b.filetype = 1 THEN 'State Department'
                     WHEN b.filetype = 2 THEN 'State Operated School'
                     WHEN b.filetype = 3 THEN 'County Center'
                     WHEN b.filetype = 4 THEN 'County Operated School'
                     WHEN b.filetype = 5 THEN 'District'
                     WHEN b.filetype = 7 THEN 'Public School'
                     WHEN b.filetype = 9 THEN 'Private School'
                     WHEN b.filetype = 10 THEN 'Catholic School'
                     WHEN b.filetype = 13 THEN 'Bureau of Indian Affairs (BIA) School'
                     WHEN b.filetype = 14 THEN 'Other'
                     WHEN b.filetype = 15 THEN 'Other'
                     WHEN b.filetype = 36 THEN 'Charter Management Organization'
                     ELSE 'QACheck' -- adding in "check" value for QA purposes
                     END                                        AS ava_institutiontype_displayname,
                 -- creation of stakeholder type
                 CASE
                     WHEN dc.crm_field IS NOT NULL THEN dc.new_value
                     WHEN b.filetype IN (1, 3, 14) THEN 'Government Agency'
                     WHEN b.filetype IN (2, 4, 7, 9, 10, 13) THEN 'School'
                     WHEN b.filetype IN (5, 15) THEN 'District'
                     WHEN b.filetype = 36 THEN 'Charter Management Organization'
                     ELSE 'QACheck' -- adding in "check" value for QA purposes
                     END                                        AS ava_stakeholdertype,
                 -- cleaning zip codes
                 CASE
                     WHEN NULLIF(mzipext, '') IS NOT NULL THEN CONCAT(LPAD(mzipcode::text, 5, '0'), '-',
                                                                      LPAD(mzipext::text, 4, '0'))
                     ELSE mzipcode::text
                     END                                        AS ava_address1_postalcode,
                 CASE
                     WHEN NULLIF(pzipext, '') IS NOT NULL THEN CONCAT(LPAD(pzipcode::text, 5, '0'), '-',
                                                                      LPAD(pzipext::text, 4, '0'))
                     ELSE pzipcode::text
                     END                                        AS ava_address2_postalcode,

                 CONCAT(LPAD(areacode::text, 3, '0'), '-', LPAD(exchange::text, 3, '0'), '-',
                        LPAD(number::text, 4, '0'))             AS ava_telephone1,
                 -- cleaning school type
                 CASE
                     WHEN schtype = 'E' THEN 'Elementary'
                     WHEN schtype = 'M' OR schtype = 'J' THEN 'Middle'
                     WHEN schtype = 'S' THEN 'High'
                     WHEN schtype IN ('A', 'C', 'P', 'V') THEN 'Other'
                     WHEN schtype IN ('2', '4', '8', 'G')
                         THEN 'Higher Ed - Check' -- There shouldn't be any higher ed, but QA this
                     END                                        AS ava_schoollevel,
                 -- cleaning zipmetro
                 CASE
                     WHEN zipmetro = 'R' THEN 'Rural'
                     WHEN zipmetro = 'S' THEN 'Suburb'
                     WHEN zipmetro = 'U' THEN 'City'
                     WHEN zipmetro = 'T' THEN 'Town'
                     WHEN zipmetro IS NULL THEN 'No Data'
                     END                                        AS ava_locale,
                 -- cleaning lowgrade
                 CASE
                     WHEN lowgrade = 'K' THEN 'KG'
                     WHEN speced = '*' THEN 'PK'
                     -- What about instances where speced = 'Y' and lowgrade is null (~1k records)? WHEN speced = 'Y' AND lowgrade IS NULL THEN 'PK'?
                     -- ONLY NEEDED FOR * CASE
                     ELSE lowgrade
                     END                                        AS ava_lowgrade,
                 -- cleaning highgrade
                 CASE
                     WHEN highgrade = 'K' THEN 'KG'
                     WHEN speced = '*' THEN '12'
                     -- ONLY NEEDED FOR * CASE
                     ELSE highgrade
                     END                                        AS ava_highgrade,
                 -- cleaning charter status
                 CASE
                     WHEN charter = 'Y' THEN 1
                     ELSE 0
                     END                                        AS ava_charter,
                 -- cleaning before/after status
                 CASE
                     WHEN beforeaft = 'Y' THEN 1
                     ELSE 0
                     END                                        AS ava_beforeafterprograms,
                 -- cleaning teched status
                 CASE
                     WHEN cteched = 'Y' OR cteched = '*' THEN 1
                     ELSE 0
                     END                                        AS ava_cteched,
                 -- cleaning magnet status
                 CASE
                     WHEN magnet IN ('S', 'P') THEN 1
                     ELSE 0
                     END                                        AS ava_magnet,
                 -- cleaning Title 1 status
                 CASE
                     WHEN NULLIF(stu_need_per, '') IS NOT NULL AND stu_need_per::INTEGER >= 40
                         THEN 1
                     WHEN NULLIF(stu_need_per, '') IS NOT NULL AND stu_need_per::INTEGER < 40 THEN 0
                     WHEN (NULLIF(stu_need_per, '') IS NULL AND od.frl_percent IS NOT NULL AND od.is_title_1) THEN 1
                     WHEN (NULLIF(stu_need_per, '') IS NULL AND od.frl_percent IS NOT NULL AND od.is_title_1 = FALSE)
                         THEN 0
                     ELSE NULL
                     END                                        AS ava_title1,
                 -- ethnicity data
                 NULLIF(b.perasian, '')::INTEGER                AS perasian_int,
                 NULLIF(b.perblack, '')::INTEGER                AS perblack_int,
                 NULLIF(b.perindian, '')::INTEGER               AS perindian_int,
                 NULLIF(b.perhisp, '')::INTEGER                 AS perhisp_int,
                 NULLIF(b.perwhite, '')::INTEGER                AS perwhite_int,

--                  CASE
--                      WHEN (b.perblack IS NULL) AND od.african_american_percent IS NOT NULL THEN od.african_american_percent
--                      WHEN (b.perblack IS NULL) AND od.african_american_percent IS NULL THEN NULL
--                      ELSE b.perblack::INTEGER
--                      END                            AS perblack_int,
--                  CASE
--                      WHEN (b.perindian IS NULL) AND od.native_american_percent IS NOT NULL THEN od.native_american_percent
--                      WHEN (b.perindian IS NULL) AND od.native_american_percent IS NULL THEN NULL
--                      ELSE b.perindian::INTEGER
--                      END                            AS perindian_int,
--                  CASE
--                      WHEN (b.perhisp IS NULL) AND od.hispanic_percent IS NOT NULL THEN od.hispanic_percent
--                      WHEN (b.perhisp IS NULL) AND od.hispanic_percent IS NULL THEN NULL
--                      ELSE b.perhisp::INTEGER
--                      END                            AS perhisp_int,
--                  CASE
--                      WHEN (b.perwhite IS NULL) AND od.caucasian_percent IS NOT NULL THEN od.caucasian_percent
--                      WHEN (b.perwhite IS NULL) AND od.caucasian_percent IS NULL THEN NULL
--                      ELSE b.perwhite::INTEGER
--                      END                            AS perwhite_int,
                 -- cleaning school open/close status
                 CASE
                     WHEN l.status_bld = 'O' AND LENGTH(l.date::varchar) = 7
                         THEN CONCAT(LEFT(l.date::varchar, 1), '/', RIGHT(LEFT(l.date::varchar, -4), 2), '/',
                                     (RIGHT(l.date::varchar, 4)))
                     WHEN l.status_bld = 'O' AND LENGTH(l.date::varchar) = 8
                         THEN CONCAT(LEFT(l.date::varchar, 2), '/', RIGHT(LEFT(l.date::varchar, -4), 2), '/',
                                     (RIGHT(l.date::varchar, 4)))
                     END                                        AS ava_dateschoolopened
             FROM temp_mdr_building b
                      LEFT JOIN temp_mdr_list_ocr AS l ON b.pid::varchar = l.pid::varchar AND l.status_bld = 'O'
                      LEFT JOIN mdr.dma_import AS d ON NULLIF(b.dma, '')::int = d.dma_code
                      LEFT JOIN live_data.organizations o ON o.pid::varchar = b.pid::varchar
                      LEFT JOIN public.organization_demographics od ON od.organization_id = o.id
                      LEFT JOIN mdr.data_changes dc
                                ON dc.organization_pid::varchar = b.pid::varchar AND dc.crm_field IS NOT NULL
             WHERE o.deleted_at IS NULL
         ) m;

    /*
     Build the output table that will be used to import to CRM
     */
--     DROP TABLE IF EXISTS mdr_ocr_output;
--     CREATE TABLE mdr_ocr_output AS
--     SELECT *
--     FROM temp_mdr_list_ocr
--     WHERE filetype IN (1, 2, 3, 4, 5, 7, 9, 10, 13, 14, 15, 36)
--       AND status_bld IN ('C', 'R', 'X');

    RETURN 'Data is ready for import in table: mdr_output';

END;
$$;

ALTER FUNCTION process_mdr_tables(varchar, varchar) OWNER TO main;

GRANT EXECUTE ON FUNCTION process_mdr_tables(varchar, varchar) TO sql_analyst;

