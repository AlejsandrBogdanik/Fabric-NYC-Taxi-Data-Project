
<img width="1523" alt="Screenshot 2024-07-27 at 13 21 57" src="https://github.com/user-attachments/assets/01174593-158f-4504-a1a8-756f49b020b8">



For the Script Activity **“Latest Processed Date”**

```sql
select top 1 
latest_processed_pickup 
from metadata.processing_log 
where table_processed = 'staging_nyctaxi_yellow'
order by latest_processed_pickup desc;
```

---

Pipeline expression for **v_date** Set Variable activity

```sql
@formatDateTime(addToTime(activity('Latest Processed Date').output.resultSets[0].rows[0].latest_processed_pickup, 1, 'Month'), 'yyyy-MM')
```

---

**Copy to Staging**

Pre Copy Script

<img width="512" alt="Screenshot 2024-07-27 at 13 22 39" src="https://github.com/user-attachments/assets/863b1d31-0366-4c4d-8ba7-466bb344d675">


---

For the Stored Procedure Activity **“SP Removing Outlier Dates”.**

Created the Stored Procedure **stg.data_cleaning_stg** in the Data Warehouse using the code below.

```sql
create procedure stg.data_cleaning_stg
@end_date datetime2,
@start_date datetime2
as
delete from stg.nyc_taxi_yellow where tpep_pickup_datetime < @start_date or tpep_pickup_datetime > @end_date;
```

![Screenshot 2024-07-27 at 13.12.29.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/450b9bdd-84b1-4382-b4d1-e7644f764103/f12d9be5-16a1-44bb-bc3e-63e27e57a5c5/Screenshot_2024-07-27_at_13.12.29.png)

---

For the Stored Procedure Activity **“SP Loading Staging Metadata”.**

Code to create the **metadata.processing_log** table.

```sql
create table metadata.processing_log
(
	pipeline_run_id varchar(255), 
	table_processed varchar(255), 
	rows_processed INT, 
	latest_processed_pickup datetime2(6),
	processed_datetime datetime2(6)
);
```

Created the Stored Procedure **metadata.insert_staging_metadata** in the Data Warehouse using the code below.

```sql
CREATE PROCEDURE metadata.insert_staging_metadata
    @pipeline_run_id VARCHAR(255),
    @table_name VARCHAR(255),
    @processed_date DATETIME
AS
    INSERT INTO metadata.processing_log (pipeline_run_id, table_processed, rows_processed, latest_processed_pickup, processed_datetime)
    SELECT
        @pipeline_run_id AS pipeline_id,
        @table_name AS table_processed,
        COUNT(*) AS rows_processed,
        MAX(tpep_pickup_datetime) AS latest_processed_pickup,
        @processed_date AS processed_datetime
    FROM stg.nyc_taxi_yellow;
```

![Screenshot 2024-07-27 at 13.12.55.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/450b9bdd-84b1-4382-b4d1-e7644f764103/22bc1819-f883-4323-9516-48a6e28ed0dd/Screenshot_2024-07-27_at_13.12.55.png)
