SELECT public.sp_baseline_responses(2000, 3, 300, '2020-12-15');
SELECT public.sp_latest_responses(2000, 3, 300, '2020-12-15');

SELECT kw.p2orgid                                                 AS "Organization ID",
       kw.account_id                                              AS "Account ID",
       o.name                                                     AS "Site Name",
       kw.funder                                                  AS "HFSF or CMG/CDC REACH?",
       DATE(LEAST(br."caq-1_date", br."caq-2_date", br."caq-3_date", br."caq-4_date", br."caq-5_date", br."caq-6_date",
                  br."caq-7_date",
                  br."caq-8_date", br."caq-9_date", br."caq-10_date", br."caq-11_date", br."caq-12_date",
                  br."caq-13_date", br."caq-14_date",
                  br."caq-15_date", br."caq-16_date", br."caq-17_date", br."caq-18_date", br."caq-19_date",
                  br."evs-1_date", br."evs-2_date",
                  br."evs-3_date", br."evs-4_date", br."evs-5_date", br."pgs-1_date", br."pgs-2_date", br."pgs-3_date",
                  br."pgs-4_date",
                  br."pgs-5_date", br."pgs-6_date", br."pgs-7_date", br."pgs-8_date", br."sos-1_date", br."sos-2_date",
                  br."sos-3_date",
                  br."sos-4_date", br."sos-5_date", br."sos-6_date", br."sos-7_date", br."sos-8_date", br."sos-9_date",
                  br."sos-10_date",
                  br."sos-11_date", br."stf-1_date", br."stf-2_date", br."stf-3_date", br."stf-4_date",
                  br."stf-5_date"))                               AS "Assessment Start",
       GREATEST(lr."caq-1_date", lr."caq-2_date", lr."caq-3_date", lr."caq-4_date", lr."caq-5_date", lr."caq-6_date",
                lr."caq-7_date",
                lr."caq-8_date", lr."caq-9_date", lr."caq-10_date", lr."caq-11_date", lr."caq-12_date",
                lr."caq-13_date", lr."caq-14_date",
                lr."caq-15_date", lr."caq-16_date", lr."caq-17_date", lr."caq-18_date", lr."caq-19_date",
                lr."evs-1_date", lr."evs-2_date",
                lr."evs-3_date", lr."evs-4_date", lr."evs-5_date", lr."pgs-1_date", lr."pgs-2_date", lr."pgs-3_date",
                lr."pgs-4_date",
                lr."pgs-5_date", lr."pgs-6_date", lr."pgs-7_date", lr."pgs-8_date", lr."sos-1_date", lr."sos-2_date",
                lr."sos-3_date",
                lr."sos-4_date", lr."sos-5_date", lr."sos-6_date", lr."sos-7_date", lr."sos-8_date", lr."sos-9_date",
                lr."sos-10_date",
                lr."sos-11_date", lr."stf-1_date", lr."stf-2_date", lr."stf-3_date", lr."stf-4_date",
                lr."stf-5_date")                                  AS "Assessment Update",
       CASE
           WHEN (brct.cq_baselined = TRUE AND brct.es_baselined = TRUE AND brct.ps_baselined = TRUE AND
                 brct.ss_baselined = TRUE AND brct.st_baselined = TRUE)
               THEN GREATEST(brct.cq_baseline_date, brct.es_baseline_date, brct.ps_baseline_date, brct.ss_baseline_date,
                             brct.st_baseline_date)
           ELSE NULL
           END                                                    AS "Assessment Baseline",
       SUM(
                   CASE WHEN lr."caq-1" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."caq-2" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."caq-3" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."caq-4" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."caq-5" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."caq-6" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."caq-7" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."caq-8" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."caq-9" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."caq-10" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."caq-11" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."caq-12" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."caq-13" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."caq-14" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."caq-15" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."caq-16" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."caq-17" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."caq-18" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."caq-19" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."evs-1" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."evs-2" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."evs-3" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."evs-4" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."evs-5" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."pgs-1" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."pgs-2" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."pgs-3" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."pgs-4" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."pgs-5" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."pgs-6" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."pgs-7" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."pgs-8" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."sos-1" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."sos-2" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."sos-3" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."sos-4" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."sos-5" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."sos-6" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."sos-7" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."sos-8" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."sos-9" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."sos-10" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."sos-11" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."stf-1" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."stf-2" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."stf-3" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."stf-4" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."stf-5" = '3' THEN 1 ELSE 0 END)  AS "Number at Best Practice - Overall",
       SUM(
                   CASE WHEN lr."caq-1" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."caq-2" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."caq-3" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."caq-4" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."caq-5" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."caq-6" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."caq-7" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."caq-8" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."caq-9" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."caq-10" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."caq-11" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."caq-12" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."caq-13" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."caq-14" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."caq-15" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."caq-16" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."caq-17" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."caq-18" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."caq-19" = '3' THEN 1 ELSE 0 END) AS "Number at Best Practice - Content & Quality",
       SUM(
                   CASE WHEN lr."evs-1" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."evs-2" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."evs-3" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."evs-4" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."evs-5" = '3' THEN 1 ELSE 0 END)  AS "Number at Best Practice - Environmental Support",
       SUM(
                   CASE WHEN lr."pgs-1" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."pgs-2" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."pgs-3" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."pgs-4" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."pgs-5" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."pgs-6" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."pgs-7" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."pgs-8" = '3' THEN 1 ELSE 0 END)  AS "Number at Best Practice - Program Support",
       SUM(
                   CASE WHEN lr."sos-1" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."sos-2" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."sos-3" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."sos-4" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."sos-5" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."sos-6" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."sos-7" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."sos-8" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."sos-9" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."sos-10" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."sos-11" = '3' THEN 1 ELSE 0 END) AS "Number at Best Practice - Social Supports",
       SUM(
                   CASE WHEN lr."stf-1" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."stf-2" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."stf-3" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."stf-4" = '3' THEN 1 ELSE 0 END +
                   CASE WHEN lr."stf-5" = '3' THEN 1 ELSE 0 END)  AS "Number at Best Practice - Staff Training",
       br."caq-1"                                                 AS "caq-1: baseline",
       br."caq-2"                                                 AS "caq-2: baseline",
       br."caq-3"                                                 AS "caq-3: baseline",
       br."caq-4"                                                 AS "caq-4: baseline",
       br."caq-5"                                                 AS "caq-5: baseline",
       br."caq-6"                                                 AS "caq-6: baseline",
       br."caq-7"                                                 AS "caq-7: baseline",
       br."caq-8"                                                 AS "caq-8: baseline",
       br."caq-9"                                                 AS "caq-9: baseline",
       br."caq-10"                                                AS "caq-10: baseline",
       br."caq-11"                                                AS "caq-11: baseline",
       br."caq-12"                                                AS "caq-12: baseline",
       br."caq-13"                                                AS "caq-13: baseline",
       br."caq-14"                                                AS "caq-14: baseline",
       br."caq-15"                                                AS "caq-15: baseline",
       br."caq-16"                                                AS "caq-16: baseline",
       br."caq-17"                                                AS "caq-17: baseline",
       br."caq-18"                                                AS "caq-18: baseline",
       br."caq-19"                                                AS "caq-19: baseline",
       br."evs-1"                                                 AS "evs-1: baseline",
       br."evs-2"                                                 AS "evs-2: baseline",
       br."evs-3"                                                 AS "evs-3: baseline",
       br."evs-4"                                                 AS "evs-4: baseline",
       br."evs-5"                                                 AS "evs-5: baseline",
       br."pgs-1"                                                 AS "pgs-1: baseline",
       br."pgs-2"                                                 AS "pgs-2: baseline",
       br."pgs-3"                                                 AS "pgs-3: baseline",
       br."pgs-4"                                                 AS "pgs-4: baseline",
       br."pgs-5"                                                 AS "pgs-5: baseline",
       br."pgs-6"                                                 AS "pgs-6: baseline",
       br."pgs-7"                                                 AS "pgs-7: baseline",
       br."pgs-8"                                                 AS "pgs-8: baseline",
       br."sos-1"                                                 AS "sos-1: baseline",
       br."sos-2"                                                 AS "sos-2: baseline",
       br."sos-3"                                                 AS "sos-3: baseline",
       br."sos-4"                                                 AS "sos-4: baseline",
       br."sos-5"                                                 AS "sos-5: baseline",
       br."sos-6"                                                 AS "sos-6: baseline",
       br."sos-7"                                                 AS "sos-7: baseline",
       br."sos-8"                                                 AS "sos-8: baseline",
       br."sos-9"                                                 AS "sos-9: baseline",
       br."sos-10"                                                AS "sos-10: baseline",
       br."sos-11"                                                AS "sos-11: baseline",
       br."stf-1"                                                 AS "stf-1: baseline",
       br."stf-2"                                                 AS "stf-2: baseline",
       br."stf-3"                                                 AS "stf-3: baseline",
       br."stf-4"                                                 AS "stf-4: baseline",
       br."stf-5"                                                 AS "stf-5: baseline",
       lr."caq-1"                                                 AS "caq-1: latest",
       lr."caq-2"                                                 AS "caq-2: latest",
       lr."caq-3"                                                 AS "caq-3: latest",
       lr."caq-4"                                                 AS "caq-4: latest",
       lr."caq-5"                                                 AS "caq-5: latest",
       lr."caq-6"                                                 AS "caq-6: latest",
       lr."caq-7"                                                 AS "caq-7: latest",
       lr."caq-8"                                                 AS "caq-8: latest",
       lr."caq-9"                                                 AS "caq-9: latest",
       lr."caq-10"                                                AS "caq-10: latest",
       lr."caq-11"                                                AS "caq-11: latest",
       lr."caq-12"                                                AS "caq-12: latest",
       lr."caq-13"                                                AS "caq-13: latest",
       lr."caq-14"                                                AS "caq-14: latest",
       lr."caq-15"                                                AS "caq-15: latest",
       lr."caq-16"                                                AS "caq-16: latest",
       lr."caq-17"                                                AS "caq-17: latest",
       lr."caq-18"                                                AS "caq-18: latest",
       lr."caq-19"                                                AS "caq-19: latest",
       lr."evs-1"                                                 AS "evs-1: latest",
       lr."evs-2"                                                 AS "evs-2: latest",
       lr."evs-3"                                                 AS "evs-3: latest",
       lr."evs-4"                                                 AS "evs-4: latest",
       lr."evs-5"                                                 AS "evs-5: latest",
       lr."pgs-1"                                                 AS "pgs-1: latest",
       lr."pgs-2"                                                 AS "pgs-2: latest",
       lr."pgs-3"                                                 AS "pgs-3: latest",
       lr."pgs-4"                                                 AS "pgs-4: latest",
       lr."pgs-5"                                                 AS "pgs-5: latest",
       lr."pgs-6"                                                 AS "pgs-6: latest",
       lr."pgs-7"                                                 AS "pgs-7: latest",
       lr."pgs-8"                                                 AS "pgs-8: latest",
       lr."sos-1"                                                 AS "sos-1: latest",
       lr."sos-2"                                                 AS "sos-2: latest",
       lr."sos-3"                                                 AS "sos-3: latest",
       lr."sos-4"                                                 AS "sos-4: latest",
       lr."sos-5"                                                 AS "sos-5: latest",
       lr."sos-6"                                                 AS "sos-6: latest",
       lr."sos-7"                                                 AS "sos-7: latest",
       lr."sos-8"                                                 AS "sos-8: latest",
       lr."sos-9"                                                 AS "sos-9: latest",
       lr."sos-10"                                                AS "sos-10: latest",
       lr."sos-11"                                                AS "sos-11: latest",
       lr."stf-1"                                                 AS "stf-1: latest",
       lr."stf-2"                                                 AS "stf-2: latest",
       lr."stf-3"                                                 AS "stf-3: latest",
       lr."stf-4"                                                 AS "stf-4: latest",
       lr."stf-5"                                                 AS "stf-5: latest",
       CASE WHEN lr."caq-1" > br."caq-1" THEN 1 ELSE 0 END        AS "caq-1 Improvement Flag",
       CASE WHEN lr."caq-2" > br."caq-2" THEN 1 ELSE 0 END        AS "caq-2 Improvement Flag",
       CASE WHEN lr."caq-3" > br."caq-3" THEN 1 ELSE 0 END        AS "caq-3 Improvement Flag",
       CASE WHEN lr."caq-4" > br."caq-4" THEN 1 ELSE 0 END        AS "caq-4 Improvement Flag",
       CASE WHEN lr."caq-5" > br."caq-5" THEN 1 ELSE 0 END        AS "caq-5 Improvement Flag",
       CASE WHEN lr."caq-6" > br."caq-6" THEN 1 ELSE 0 END        AS "caq-6 Improvement Flag",
       CASE WHEN lr."caq-7" > br."caq-7" THEN 1 ELSE 0 END        AS "caq-7 Improvement Flag",
       CASE WHEN lr."caq-8" > br."caq-8" THEN 1 ELSE 0 END        AS "caq-8 Improvement Flag",
       CASE WHEN lr."caq-9" > br."caq-9" THEN 1 ELSE 0 END        AS "caq-9 Improvement Flag",
       CASE WHEN lr."caq-10" > br."caq-10" THEN 1 ELSE 0 END      AS "caq-10 Improvement Flag",
       CASE WHEN lr."caq-11" > br."caq-11" THEN 1 ELSE 0 END      AS "caq-11 Improvement Flag",
       CASE WHEN lr."caq-12" > br."caq-12" THEN 1 ELSE 0 END      AS "caq-12 Improvement Flag",
       CASE WHEN lr."caq-13" > br."caq-13" THEN 1 ELSE 0 END      AS "caq-13 Improvement Flag",
       CASE WHEN lr."caq-14" > br."caq-14" THEN 1 ELSE 0 END      AS "caq-14 Improvement Flag",
       CASE WHEN lr."caq-15" > br."caq-15" THEN 1 ELSE 0 END      AS "caq-15 Improvement Flag",
       CASE WHEN lr."caq-16" > br."caq-16" THEN 1 ELSE 0 END      AS "caq-16 Improvement Flag",
       CASE WHEN lr."caq-17" > br."caq-17" THEN 1 ELSE 0 END      AS "caq-17 Improvement Flag",
       CASE WHEN lr."caq-18" > br."caq-18" THEN 1 ELSE 0 END      AS "caq-18 Improvement Flag",
       CASE WHEN lr."caq-19" > br."caq-19" THEN 1 ELSE 0 END      AS "caq-19 Improvement Flag",
       CASE WHEN lr."evs-1" > br."evs-1" THEN 1 ELSE 0 END        AS "evs-1 Improvement Flag",
       CASE WHEN lr."evs-2" > br."evs-2" THEN 1 ELSE 0 END        AS "evs-2 Improvement Flag",
       CASE WHEN lr."evs-3" > br."evs-3" THEN 1 ELSE 0 END        AS "evs-3 Improvement Flag",
       CASE WHEN lr."evs-4" > br."evs-4" THEN 1 ELSE 0 END        AS "evs-4 Improvement Flag",
       CASE WHEN lr."evs-5" > br."evs-5" THEN 1 ELSE 0 END        AS "evs-5 Improvement Flag",
       CASE WHEN lr."pgs-1" > br."pgs-1" THEN 1 ELSE 0 END        AS "pgs-1 Improvement Flag",
       CASE WHEN lr."pgs-2" > br."pgs-2" THEN 1 ELSE 0 END        AS "pgs-2 Improvement Flag",
       CASE WHEN lr."pgs-3" > br."pgs-3" THEN 1 ELSE 0 END        AS "pgs-3 Improvement Flag",
       CASE WHEN lr."pgs-4" > br."pgs-4" THEN 1 ELSE 0 END        AS "pgs-4 Improvement Flag",
       CASE WHEN lr."pgs-5" > br."pgs-5" THEN 1 ELSE 0 END        AS "pgs-5 Improvement Flag",
       CASE WHEN lr."pgs-6" > br."pgs-6" THEN 1 ELSE 0 END        AS "pgs-6 Improvement Flag",
       CASE WHEN lr."pgs-7" > br."pgs-7" THEN 1 ELSE 0 END        AS "pgs-7 Improvement Flag",
       CASE WHEN lr."pgs-8" > br."pgs-8" THEN 1 ELSE 0 END        AS "pgs-8 Improvement Flag",
       CASE WHEN lr."sos-1" > br."sos-1" THEN 1 ELSE 0 END        AS "sos-1 Improvement Flag",
       CASE WHEN lr."sos-2" > br."sos-2" THEN 1 ELSE 0 END        AS "sos-2 Improvement Flag",
       CASE WHEN lr."sos-3" > br."sos-3" THEN 1 ELSE 0 END        AS "sos-3 Improvement Flag",
       CASE WHEN lr."sos-4" > br."sos-4" THEN 1 ELSE 0 END        AS "sos-4 Improvement Flag",
       CASE WHEN lr."sos-5" > br."sos-5" THEN 1 ELSE 0 END        AS "sos-5 Improvement Flag",
       CASE WHEN lr."sos-6" > br."sos-6" THEN 1 ELSE 0 END        AS "sos-6 Improvement Flag",
       CASE WHEN lr."sos-7" > br."sos-7" THEN 1 ELSE 0 END        AS "sos-7 Improvement Flag",
       CASE WHEN lr."sos-8" > br."sos-8" THEN 1 ELSE 0 END        AS "sos-8 Improvement Flag",
       CASE WHEN lr."sos-9" > br."sos-9" THEN 1 ELSE 0 END        AS "sos-9 Improvement Flag",
       CASE WHEN lr."sos-10" > br."sos-10" THEN 1 ELSE 0 END      AS "sos-10 Improvement Flag",
       CASE WHEN lr."sos-11" > br."sos-11" THEN 1 ELSE 0 END      AS "sos-11 Improvement Flag",
       CASE WHEN lr."stf-1" > br."stf-1" THEN 1 ELSE 0 END        AS "stf-1 Improvement Flag",
       CASE WHEN lr."stf-2" > br."stf-2" THEN 1 ELSE 0 END        AS "stf-2 Improvement Flag",
       CASE WHEN lr."stf-3" > br."stf-3" THEN 1 ELSE 0 END        AS "stf-3 Improvement Flag",
       CASE WHEN lr."stf-4" > br."stf-4" THEN 1 ELSE 0 END        AS "stf-4 Improvement Flag",
       CASE WHEN lr."stf-5" > br."stf-5" THEN 1 ELSE 0 END        AS "stf-5 Improvement Flag"
FROM public.kw_hfsf_cmg_accounts kw
         JOIN live_data.organizations o ON kw.p2orgid = o.id
         LEFT JOIN baseline_responses_ct br ON kw.p2orgid = br.organization_id
         LEFT JOIN temp_baseline_responses_mod_baselines_ct brct ON br.organization_id = brct.id
         LEFT JOIN latest_responses_ct lr ON kw.p2orgid = lr.organization_id
GROUP BY kw.p2orgid, kw.account_id, o.name, kw.funder,
         br."caq-1_date", br."caq-2_date", br."caq-3_date", br."caq-4_date", br."caq-5_date", br."caq-6_date",
         br."caq-7_date",
         br."caq-8_date", br."caq-9_date", br."caq-10_date", br."caq-11_date", br."caq-12_date", br."caq-13_date",
         br."caq-14_date",
         br."caq-15_date", br."caq-16_date", br."caq-17_date", br."caq-18_date", br."caq-19_date", br."evs-1_date",
         br."evs-2_date",
         br."evs-3_date", br."evs-4_date", br."evs-5_date", br."pgs-1_date", br."pgs-2_date", br."pgs-3_date",
         br."pgs-4_date",
         br."pgs-5_date", br."pgs-6_date", br."pgs-7_date", br."pgs-8_date", br."sos-1_date", br."sos-2_date",
         br."sos-3_date",
         br."sos-4_date", br."sos-5_date", br."sos-6_date", br."sos-7_date", br."sos-8_date", br."sos-9_date",
         br."sos-10_date",
         br."sos-11_date", br."stf-1_date", br."stf-2_date", br."stf-3_date", br."stf-4_date", br."stf-5_date",
         lr."caq-1_date", lr."caq-2_date", lr."caq-3_date", lr."caq-4_date", lr."caq-5_date", lr."caq-6_date",
         lr."caq-7_date",
         lr."caq-8_date", lr."caq-9_date", lr."caq-10_date", lr."caq-11_date", lr."caq-12_date", lr."caq-13_date",
         lr."caq-14_date",
         lr."caq-15_date", lr."caq-16_date", lr."caq-17_date", lr."caq-18_date", lr."caq-19_date", lr."evs-1_date",
         lr."evs-2_date",
         lr."evs-3_date", lr."evs-4_date", lr."evs-5_date", lr."pgs-1_date", lr."pgs-2_date", lr."pgs-3_date",
         lr."pgs-4_date",
         lr."pgs-5_date", lr."pgs-6_date", lr."pgs-7_date", lr."pgs-8_date", lr."sos-1_date", lr."sos-2_date",
         lr."sos-3_date",
         lr."sos-4_date", lr."sos-5_date", lr."sos-6_date", lr."sos-7_date", lr."sos-8_date", lr."sos-9_date",
         lr."sos-10_date",
         lr."sos-11_date", lr."stf-1_date", lr."stf-2_date", lr."stf-3_date", lr."stf-4_date", lr."stf-5_date",
         brct.cq_baselined, brct.es_baselined, brct.ps_baselined, brct.ss_baselined, brct.st_baselined,
         brct.cq_baseline_date, brct.es_baseline_date, brct.ps_baseline_date, brct.ss_baseline_date,
         brct.st_baseline_date,
         br."caq-1", br."caq-2", br."caq-3", br."caq-4", br."caq-5", br."caq-6", br."caq-7", br."caq-8", br."caq-9",
         br."caq-10",
         br."caq-11", br."caq-12", br."caq-13", br."caq-14", br."caq-15", br."caq-16", br."caq-17", br."caq-18",
         br."caq-19",
         br."evs-1", br."evs-2", br."evs-3", br."evs-4", br."evs-5", br."pgs-1", br."pgs-2", br."pgs-3", br."pgs-4",
         br."pgs-5",
         br."pgs-6", br."pgs-7", br."pgs-8", br."sos-1", br."sos-2", br."sos-3", br."sos-4", br."sos-5", br."sos-6",
         br."sos-7",
         br."sos-8", br."sos-9", br."sos-10", br."sos-11", br."stf-1", br."stf-2", br."stf-3", br."stf-4", br."stf-5",
         lr."caq-1",
         lr."caq-2", lr."caq-3", lr."caq-4", lr."caq-5", lr."caq-6", lr."caq-7", lr."caq-8", lr."caq-9", lr."caq-10",
         lr."caq-11",
         lr."caq-12", lr."caq-13", lr."caq-14", lr."caq-15", lr."caq-16", lr."caq-17", lr."caq-18", lr."caq-19",
         lr."evs-1", lr."evs-2",
         lr."evs-3", lr."evs-4", lr."evs-5", lr."pgs-1", lr."pgs-2", lr."pgs-3", lr."pgs-4", lr."pgs-5", lr."pgs-6",
         lr."pgs-7",
         lr."pgs-8", lr."sos-1", lr."sos-2", lr."sos-3", lr."sos-4", lr."sos-5", lr."sos-6", lr."sos-7", lr."sos-8",
         lr."sos-9",
         lr."sos-10", lr."sos-11", lr."stf-1", lr."stf-2", lr."stf-3", lr."stf-4", lr."stf-5";


SELECT COUNT(DISTINCT o.id) FILTER (WHERE pb.plan_bucket_template_id = 1)                                         AS "Number Sites with 1+ In Progress AP Item - Overall",
       COUNT(DISTINCT o.id)
       FILTER (WHERE pb.plan_bucket_template_id = 1 AND ci.module_id = 14)                                        AS "Number Sites with 1+ In Progress AP Item - C&Q",
       COUNT(DISTINCT o.id)
       FILTER (WHERE pb.plan_bucket_template_id = 1 AND ci.module_id = 15)                                        AS "Number Sites with 1+ In Progress AP Item - ST",
       COUNT(DISTINCT o.id)
       FILTER (WHERE pb.plan_bucket_template_id = 1 AND ci.module_id = 16)                                        AS "Number Sites with 1+ In Progress AP Item - SS",
       COUNT(DISTINCT o.id)
       FILTER (WHERE pb.plan_bucket_template_id = 1 AND ci.module_id = 17)                                        AS "Number Sites with 1+ In Progress AP Item - PS",
       COUNT(DISTINCT o.id)
       FILTER (WHERE pb.plan_bucket_template_id = 1 AND ci.module_id = 18)                                        AS "Number Sites with 1+ In Progress AP Item - EQ",
       COUNT(DISTINCT o.id) FILTER (WHERE pb.plan_bucket_template_id = 2)                                         AS "Number Sites with 1+ Done AP Item - Overall",
       COUNT(DISTINCT o.id)
       FILTER (WHERE pb.plan_bucket_template_id = 2 AND ci.module_id = 14)                                        AS "Number Sites with 1+ Done AP Item - C&Q",
       COUNT(DISTINCT o.id)
       FILTER (WHERE pb.plan_bucket_template_id = 2 AND ci.module_id = 15)                                        AS "Number Sites with 1+ Done AP Item - ST",
       COUNT(DISTINCT o.id)
       FILTER (WHERE pb.plan_bucket_template_id = 2 AND ci.module_id = 16)                                        AS "Number Sites with 1+ Done AP Item - SS",
       COUNT(DISTINCT o.id)
       FILTER (WHERE pb.plan_bucket_template_id = 2 AND ci.module_id = 17)                                        AS "Number Sites with 1+ Done AP Item - PS",
       COUNT(DISTINCT o.id)
       FILTER (WHERE pb.plan_bucket_template_id = 2 AND ci.module_id = 18)                                        AS "Number Sites with 1+ Done AP Item - EQ",
       COUNT(DISTINCT o.id)
       FILTER (WHERE pb.plan_bucket_template_id IN (1, 2))                                                        AS "Number Sites with 1+ In Progress or Done AP Item - Overall",
       COUNT(DISTINCT o.id)
       FILTER (WHERE pb.plan_bucket_template_id IN (1, 2) AND ci.module_id = 14)                                  AS "Number Sites with 1+ In Progress or Done AP Item - C&Q",
       COUNT(DISTINCT o.id)
       FILTER (WHERE pb.plan_bucket_template_id IN (1, 2) AND ci.module_id = 15)                                  AS "Number Sites with 1+ In Progress or Done AP Item - ST",
       COUNT(DISTINCT o.id)
       FILTER (WHERE pb.plan_bucket_template_id IN (1, 2) AND ci.module_id = 16)                                  AS "Number Sites with 1+ In Progress or Done AP Item - SS",
       COUNT(DISTINCT o.id)
       FILTER (WHERE pb.plan_bucket_template_id IN (1, 2) AND ci.module_id = 17)                                  AS "Number Sites with 1+ In Progress or Done AP Item - PS",
       COUNT(DISTINCT o.id)
       FILTER (WHERE pb.plan_bucket_template_id IN (1, 2) AND ci.module_id = 18)                                  AS "Number Sites with 1+ In Progress or Done AP Item - EQ",

       COUNT(DISTINCT o.id)
       FILTER (WHERE kw.funder = 'HFSF' AND pb.plan_bucket_template_id = 1)                                       AS "HFSF - Number Sites with 1+ In Progress AP Item - Overall",
       COUNT(DISTINCT o.id) FILTER (WHERE kw.funder = 'HFSF' AND pb.plan_bucket_template_id = 1 AND ci.module_id =
                                                                                                    14)           AS "HFSF - Number Sites with 1+ In Progress AP Item - C&Q",
       COUNT(DISTINCT o.id) FILTER (WHERE kw.funder = 'HFSF' AND pb.plan_bucket_template_id = 1 AND ci.module_id =
                                                                                                    15)           AS "HFSF - Number Sites with 1+ In Progress AP Item - ST",
       COUNT(DISTINCT o.id) FILTER (WHERE kw.funder = 'HFSF' AND pb.plan_bucket_template_id = 1 AND ci.module_id =
                                                                                                    16)           AS "HFSF - Number Sites with 1+ In Progress AP Item - SS",
       COUNT(DISTINCT o.id) FILTER (WHERE kw.funder = 'HFSF' AND pb.plan_bucket_template_id = 1 AND ci.module_id =
                                                                                                    17)           AS "HFSF - Number Sites with 1+ In Progress AP Item - PS",
       COUNT(DISTINCT o.id) FILTER (WHERE kw.funder = 'HFSF' AND pb.plan_bucket_template_id = 1 AND ci.module_id =
                                                                                                    18)           AS "HFSF - Number Sites with 1+ In Progress AP Item - EQ",
       COUNT(DISTINCT o.id)
       FILTER (WHERE kw.funder = 'HFSF' AND pb.plan_bucket_template_id = 2)                                       AS "HFSF - Number Sites with 1+ Done AP Item - Overall",
       COUNT(DISTINCT o.id) FILTER (WHERE kw.funder = 'HFSF' AND pb.plan_bucket_template_id = 2 AND ci.module_id =
                                                                                                    14)           AS "HFSF - Number Sites with 1+ Done AP Item - C&Q",
       COUNT(DISTINCT o.id) FILTER (WHERE kw.funder = 'HFSF' AND pb.plan_bucket_template_id = 2 AND ci.module_id =
                                                                                                    15)           AS "HFSF - Number Sites with 1+ Done AP Item - ST",
       COUNT(DISTINCT o.id) FILTER (WHERE kw.funder = 'HFSF' AND pb.plan_bucket_template_id = 2 AND ci.module_id =
                                                                                                    16)           AS "HFSF - Number Sites with 1+ Done AP Item - SS",
       COUNT(DISTINCT o.id) FILTER (WHERE kw.funder = 'HFSF' AND pb.plan_bucket_template_id = 2 AND ci.module_id =
                                                                                                    17)           AS "HFSF - Number Sites with 1+ Done AP Item - PS",
       COUNT(DISTINCT o.id) FILTER (WHERE kw.funder = 'HFSF' AND pb.plan_bucket_template_id = 2 AND ci.module_id =
                                                                                                    18)           AS "HFSF - Number Sites with 1+ Done AP Item - EQ",
       COUNT(DISTINCT o.id)
       FILTER (WHERE kw.funder = 'HFSF' AND pb.plan_bucket_template_id IN (1, 2))                                 AS "HFSF - Number Sites with 1+ In Progress or Done AP Item - Overall",
       COUNT(DISTINCT o.id) FILTER (WHERE kw.funder = 'HFSF' AND pb.plan_bucket_template_id IN (1, 2) AND ci.module_id =
                                                                                                          14)     AS "HFSF - Number Sites with 1+ In Progress or Done AP Item - C&Q",
       COUNT(DISTINCT o.id) FILTER (WHERE kw.funder = 'HFSF' AND pb.plan_bucket_template_id IN (1, 2) AND ci.module_id =
                                                                                                          15)     AS "HFSF - Number Sites with 1+ In Progress or Done AP Item - ST",
       COUNT(DISTINCT o.id) FILTER (WHERE kw.funder = 'HFSF' AND pb.plan_bucket_template_id IN (1, 2) AND ci.module_id =
                                                                                                          16)     AS "HFSF - Number Sites with 1+ In Progress or Done AP Item - SS",
       COUNT(DISTINCT o.id) FILTER (WHERE kw.funder = 'HFSF' AND pb.plan_bucket_template_id IN (1, 2) AND ci.module_id =
                                                                                                          17)     AS "HFSF - Number Sites with 1+ In Progress or Done AP Item - PS",
       COUNT(DISTINCT o.id) FILTER (WHERE kw.funder = 'HFSF' AND pb.plan_bucket_template_id IN (1, 2) AND ci.module_id =
                                                                                                          18)     AS "HFSF - Number Sites with 1+ In Progress or Done AP Item - EQ",

       COUNT(DISTINCT o.id)
       FILTER (WHERE kw.funder = 'CMG, CDC REACH' AND pb.plan_bucket_template_id = 1)                             AS "CMG - Number Sites with 1+ In Progress AP Item - Overall",
       COUNT(DISTINCT o.id) FILTER (WHERE kw.funder = 'CMG, CDC REACH' AND pb.plan_bucket_template_id = 1 AND
                                          ci.module_id =
                                          14)                                                                     AS "CMG - Number Sites with 1+ In Progress AP Item - C&Q",
       COUNT(DISTINCT o.id) FILTER (WHERE kw.funder = 'CMG, CDC REACH' AND pb.plan_bucket_template_id = 1 AND
                                          ci.module_id =
                                          15)                                                                     AS "CMG - Number Sites with 1+ In Progress AP Item - ST",
       COUNT(DISTINCT o.id) FILTER (WHERE kw.funder = 'CMG, CDC REACH' AND pb.plan_bucket_template_id = 1 AND
                                          ci.module_id =
                                          16)                                                                     AS "CMG - Number Sites with 1+ In Progress AP Item - SS",
       COUNT(DISTINCT o.id) FILTER (WHERE kw.funder = 'CMG, CDC REACH' AND pb.plan_bucket_template_id = 1 AND
                                          ci.module_id =
                                          17)                                                                     AS "CMG - Number Sites with 1+ In Progress AP Item - PS",
       COUNT(DISTINCT o.id) FILTER (WHERE kw.funder = 'CMG, CDC REACH' AND pb.plan_bucket_template_id = 1 AND
                                          ci.module_id =
                                          18)                                                                     AS "CMG - Number Sites with 1+ In Progress AP Item - EQ",
       COUNT(DISTINCT o.id)
       FILTER (WHERE kw.funder = 'CMG, CDC REACH' AND pb.plan_bucket_template_id = 2)                             AS "CMG - Number Sites with 1+ Done AP Item - Overall",
       COUNT(DISTINCT o.id) FILTER (WHERE kw.funder = 'CMG, CDC REACH' AND pb.plan_bucket_template_id = 2 AND
                                          ci.module_id =
                                          14)                                                                     AS "CMG - Number Sites with 1+ Done AP Item - C&Q",
       COUNT(DISTINCT o.id) FILTER (WHERE kw.funder = 'CMG, CDC REACH' AND pb.plan_bucket_template_id = 2 AND
                                          ci.module_id =
                                          15)                                                                     AS "CMG - Number Sites with 1+ Done AP Item - ST",
       COUNT(DISTINCT o.id) FILTER (WHERE kw.funder = 'CMG, CDC REACH' AND pb.plan_bucket_template_id = 2 AND
                                          ci.module_id =
                                          16)                                                                     AS "CMG - Number Sites with 1+ Done AP Item - SS",
       COUNT(DISTINCT o.id) FILTER (WHERE kw.funder = 'CMG, CDC REACH' AND pb.plan_bucket_template_id = 2 AND
                                          ci.module_id =
                                          17)                                                                     AS "CMG - Number Sites with 1+ Done AP Item - PS",
       COUNT(DISTINCT o.id) FILTER (WHERE kw.funder = 'CMG, CDC REACH' AND pb.plan_bucket_template_id = 2 AND
                                          ci.module_id =
                                          18)                                                                     AS "CMG - Number Sites with 1+ Done AP Item - EQ",
       COUNT(DISTINCT o.id)
       FILTER (WHERE kw.funder = 'CMG, CDC REACH' AND pb.plan_bucket_template_id IN (1, 2))                       AS "CMG - Number Sites with 1+ In Progress or Done AP Item - Overall",
       COUNT(DISTINCT o.id) FILTER (WHERE kw.funder = 'CMG, CDC REACH' AND pb.plan_bucket_template_id IN (1, 2) AND
                                          ci.module_id =
                                          14)                                                                     AS "CMG - Number Sites with 1+ In Progress or Done AP Item - C&Q",
       COUNT(DISTINCT o.id) FILTER (WHERE kw.funder = 'CMG, CDC REACH' AND pb.plan_bucket_template_id IN (1, 2) AND
                                          ci.module_id =
                                          15)                                                                     AS "CMG - Number Sites with 1+ In Progress or Done AP Item - ST",
       COUNT(DISTINCT o.id) FILTER (WHERE kw.funder = 'CMG, CDC REACH' AND pb.plan_bucket_template_id IN (1, 2) AND
                                          ci.module_id =
                                          16)                                                                     AS "CMG - Number Sites with 1+ In Progress or Done AP Item - SS",
       COUNT(DISTINCT o.id) FILTER (WHERE kw.funder = 'CMG, CDC REACH' AND pb.plan_bucket_template_id IN (1, 2) AND
                                          ci.module_id =
                                          17)                                                                     AS "CMG - Number Sites with 1+ In Progress or Done AP Item - PS",
       COUNT(DISTINCT o.id) FILTER (WHERE kw.funder = 'CMG, CDC REACH' AND pb.plan_bucket_template_id IN (1, 2) AND
                                          ci.module_id =
                                          18)                                                                     AS "CMG - Number Sites with 1+ In Progress or Done AP Item - EQ"
FROM live_data.criterion_instances ci
         JOIN live_data.sets s ON s.id = 3 AND ci.set_id = s.id AND ci.deleted_at IS NULL
         JOIN live_data.organization_types ot ON ot.id = s.organization_type_id
         JOIN live_data.organizations o
              ON o.organization_type_id = s.organization_type_id AND o.deleted_at IS NULL AND is_demo = FALSE
         JOIN public.kw_hfsf_cmg_accounts kw ON o.id = kw.p2orgid
         LEFT JOIN live_data.criterion_grade_level cgl
                   ON cgl.criterion_id = ci.criterion_id AND o.grade_level_ids::jsonb ? cgl.grade_level_id
         LEFT JOIN live_data.plans p ON o.id = p.organization_id
         LEFT JOIN live_data.plan_items pi ON p.id = pi.plan_id AND pi.criterion_id = CASE
                                                                                          WHEN ot.graded
                                                                                              THEN cgl.criterion_id
                                                                                          ELSE ci.criterion_id END
         LEFT JOIN live_data.plan_buckets pb ON pi.plan_bucket_id = pb.id;