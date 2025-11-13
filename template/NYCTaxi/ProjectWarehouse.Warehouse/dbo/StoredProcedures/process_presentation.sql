CREATE PROCEDURE dbo.process_presentation
AS
INSERT INTO dbo.nyctaxi_yellow
    SELECT
    CASE 
        WHEN nty.VendorID = 1 THEN 'Creative Mobile Technologies'
        WHEN nty.VendorID = 2 THEN 'VeriFone'
        else 'Unknown'
    end as vendor,
    format(nty.tpep_pickup_datetime,'yyyy-MM-dd') as tpep_pickup_datetime,
    format(nty.tpep_dropoff_datetime,'yyyy-MM-dd') as tpep_dropoff_datetime,
    lu1.Borough as pu_borough,
    lu1.Zone as pu_zone,
    lu2.Borough as pu_borough,
    lu2.Zone as pu_zone,
    CASE 
        WHEN nty.payment_type = 1 THEN 'Credit Card'
        WHEN nty.payment_type = 2 THEN 'Cash'
        WHEN nty.payment_type = 3 THEN 'No Charge'
        WHEN nty.payment_type = 4 THEN 'Dispute'
        WHEN nty.payment_type = 5 THEN 'Unknown'
        WHEN nty.payment_type = 6 THEN 'Voided Trip'
        else 'Unknown'
    end as payment_method,
    nty.passenger_count as passenger_count,
    nty.trip_distance as trip_distance,
    nty.total_amount as total_amount
    from stg.nyc_taxi_yellow nty
    left join stg.taxi_zone_lookup lu1
    on nty.PULocationID = lu1.LocationID
    left join stg.taxi_zone_lookup lu2
    on nty.DOLocationID = lu2.LocationID;