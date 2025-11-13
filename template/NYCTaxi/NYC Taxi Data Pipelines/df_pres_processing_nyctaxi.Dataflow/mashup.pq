[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "stg nyctaxi_yellow_DataDestination", IsNewTarget = false], Settings = [Kind = "Manual", AllowCreation = false, ColumnSettings = [Mappings = {[SourceColumnName = "vendor", DestinationColumnName = "vendor"], [SourceColumnName = "tpep_pickup_datetime", DestinationColumnName = "tpep_pickup_datetime"], [SourceColumnName = "tpep_dropoff_datetime", DestinationColumnName = "tpep_dropoff_datetime"], [SourceColumnName = "pu_borough", DestinationColumnName = "pu_borough"], [SourceColumnName = "pu_zone", DestinationColumnName = "pu_zone"], [SourceColumnName = "do_borough", DestinationColumnName = "do_borough"], [SourceColumnName = "do_zone", DestinationColumnName = "do_zone"], [SourceColumnName = "payment_method", DestinationColumnName = "payment_method"], [SourceColumnName = "passenger_count", DestinationColumnName = "passenger_count"], [SourceColumnName = "trip_distance", DestinationColumnName = "trip_distance"], [SourceColumnName = "total_amount", DestinationColumnName = "total_amount"]}], DynamicSchema = false, UpdateMethod = [Kind = "Append"], TypeSettings = [Kind = "Table"]]]}]
shared #"stg nyctaxi_yellow" = let
  Джерело = Fabric.Warehouse(null),
  Навігація = Джерело{[workspaceId = "298604c0-147d-4376-aa69-eb45754f28df"]}[Data],
  #"Навігація 1" = Навігація{[warehouseId = "fc6b09fd-3e52-4385-b51b-a23a0ed3ad1b"]}[Data],
  #"Навігація 2" = #"Навігація 1"{[Schema = "stg", Item = "nyctaxi_yellow"]}[Data],
  #"Видалено стовпці" = Table.RemoveColumns(#"Навігація 2", {"RatecodeID", "store_and_fwd_flag", "fare_amount", "extra", "mta_tax", "tip_amount", "tolls_amount", "improvement_surcharge", "congestion_surcharge", "Airport_fee"}),
  #"Вставлено умовний стовпець" = Table.AddColumn(#"Видалено стовпці", "vendor", each if [VendorID] = 1 then "Creative Mobile Technologies" else if [VendorID] = 2 then "VeriFone" else "Unknown"),
  #"Видалено стовпці 1" = Table.RemoveColumns(#"Вставлено умовний стовпець", {"VendorID"}),
  #"Вставлено умовний стовпець 1" = Table.AddColumn(#"Видалено стовпці 1", "payment_method ", each if [payment_type] = 1 then "Credit Card" else if [payment_type] = 2 then "Cash" else if [payment_type] = 3 then "No Charge" else if [payment_type] = 4 then "Dispute" else if [payment_type] = 5 then "Unknown" else if [payment_type] = 6 then "Voided Trip" else "Unknown"),
  #"Видалено стовпці 2" = Table.RemoveColumns(#"Вставлено умовний стовпець 1", {"payment_type"}),
  #"Перейменовано стовпці" = Table.RenameColumns(#"Видалено стовпці 2", {{"DOLocationID", "do_location_id"}, {"PULocationID", "pu_location_id"}}),
  #"Обчислено дату" = Table.TransformColumns(#"Перейменовано стовпці", {{"tpep_dropoff_datetime", each DateTime.Date(_), type nullable date}, {"tpep_pickup_datetime", each DateTime.Date(_), type nullable date}}),
  #"Змінено тип стовпця" = Table.TransformColumnTypes(#"Обчислено дату", {{"vendor", type text}, {"payment_method ", type text}}),
  #"Об’єднано запити" = Table.NestedJoin(#"Змінено тип стовпця", {"pu_location_id"}, #"stg taxi_zone_lookup", {"LocationID"}, "stg taxi_zone_lookup", JoinKind.LeftOuter),
  #"Розгорнуто stg taxi_zone_lookup" = Table.ExpandTableColumn(#"Об’єднано запити", "stg taxi_zone_lookup", {"Borough", "Zone"}, {"Borough", "Zone"}),
  #"Перейменовано стовпці 1" = Table.RenameColumns(#"Розгорнуто stg taxi_zone_lookup", {{"Borough", "pu_borough"}, {"Zone", "pu_zone"}}),
  #"Видалено стовпці 3" = Table.RemoveColumns(#"Перейменовано стовпці 1", {"pu_location_id"}),
  #"Об’єднано запити 1" = Table.NestedJoin(#"Видалено стовпці 3", {"do_location_id"}, #"stg taxi_zone_lookup", {"LocationID"}, "stg taxi_zone_lookup", JoinKind.LeftOuter),
  #"Розгорнуто stg taxi_zone_lookup 1" = Table.ExpandTableColumn(#"Об’єднано запити 1", "stg taxi_zone_lookup", {"Borough", "Zone"}, {"Borough", "Zone"}),
  #"Перейменовано стовпці 2" = Table.RenameColumns(#"Розгорнуто stg taxi_zone_lookup 1", {{"Borough", "do_borough"}, {"Zone", "do_zone"}}),
  #"Видалено стовпці 4" = Table.RemoveColumns(#"Перейменовано стовпці 2", {"do_location_id"}),
  #"Перейменовано стовпці 3" = Table.RenameColumns(#"Видалено стовпці 4", {{"payment_method ", "payment_method"}})
in
  #"Перейменовано стовпці 3";
shared #"stg taxi_zone_lookup" = let
  Джерело = Fabric.Warehouse(null),
  Навігація = Джерело{[workspaceId = "298604c0-147d-4376-aa69-eb45754f28df"]}[Data],
  #"Навігація 1" = Навігація{[warehouseId = "fc6b09fd-3e52-4385-b51b-a23a0ed3ad1b"]}[Data],
  #"Навігація 2" = #"Навігація 1"{[Schema = "stg", Item = "taxi_zone_lookup"]}[Data],
  #"Змінено тип стовпця" = Table.TransformColumnTypes(#"Навігація 2", {{"LocationID", Int64.Type}})
in
  #"Змінено тип стовпця";
shared #"stg nyctaxi_yellow_DataDestination" = let
  Pattern = Fabric.Warehouse([HierarchicalNavigation = null, CreateNavigationProperties = false]),
  Navigation_1 = Pattern{[workspaceId = "298604c0-147d-4376-aa69-eb45754f28df"]}[Data],
  Navigation_2 = Navigation_1{[warehouseId = "fc6b09fd-3e52-4385-b51b-a23a0ed3ad1b"]}[Data],
  TableNavigation = Navigation_2{[Schema = "dbo", Item = "nyctaxi_yellow"]}[Data]
in
  TableNavigation;
