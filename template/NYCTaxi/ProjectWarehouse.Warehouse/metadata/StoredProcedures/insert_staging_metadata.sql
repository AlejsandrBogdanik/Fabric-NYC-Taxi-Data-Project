CREATE PROC metadata.insert_staging_metadata
@pipeline_run_id varchar(255),
@table_name varchar(255),
@processed_date datetime
AS
    insert into metadata.processing_log (pipeline_run_id, table_processed, rows_processed, latest_processed_pickup, processed_datetime)
    SELECT 
        @pipeline_run_id as pipeline_run_id,
        @table_name as table_processed,
        count(*) as rows_processed,
        max([tpep_pickup_datetime]) as latest_processed_pickup,
        @processed_date as processed_datetime
    from stg.nyctaxi_yellow