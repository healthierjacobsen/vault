# Structure

This section is used to house queries used for the creation of all tables, views, materialized views, and routines.


- crm - Used as a location for data to flow back and forth with CRM. As well as a means to query against some CRM data.
- live_Data - View of the P2 database (production).
- mdr - Used as a location for data processing of our data feed files from MDR.
- public - Used for the majority of the routines as well as development area.
- reporting - Used by the API to trigger summary jobs and access summary information.


## Permissions

#### sql_analyst
    GRANT USAGE ON SCHEMA crm TO sql_analyst;
    GRANT SELECT ON ALL TABLES IN SCHEMA crm TO sql_analyst;

    GRANT USAGE ON SCHEMA live_data TO sql_analyst;
    GRANT SELECT ON ALL TABLES IN SCHEMA live_data TO sql_analyst;

    GRANT USAGE ON SCHEMA mdr TO sql_analyst;
    GRANT ALL ON ALL TABLES IN SCHEMA mdr TO sql_analyst;

    GRANT USAGE ON SCHEMA public TO sql_analyst;
    GRANT ALL ON ALL TABLES IN SCHEMA public TO sql_analyst;

    GRANT USAGE ON SCHEMA reporting TO sql_analyst;
    GRANT SELECT ON ALL TABLES IN SCHEMA reporting TO sql_analyst;

#### chartio
    GRANT USAGE ON SCHEMA crm TO chartio;
    GRANT SELECT ON ALL TABLES IN SCHEMA crm TO chartio;

    GRANT USAGE ON SCHEMA live_data TO chartio;
    GRANT SELECT ON ALL TABLES IN SCHEMA live_data TO chartio;

    GRANT USAGE ON SCHEMA public TO chartio;
    GRANT SELECT ON ALL TABLES IN SCHEMA public TO chartio;