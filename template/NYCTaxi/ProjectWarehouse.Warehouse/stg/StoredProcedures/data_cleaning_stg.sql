CREATE PROC stg.data_cleaning_stg
@end_date DATETIME2,
@start_date DATETIME2
AS
DELETE FROM stg.nyctaxi_yellow WHERE tpep_pickup_datetime < @start_date or tpep_pickup_datetime > @end_date;