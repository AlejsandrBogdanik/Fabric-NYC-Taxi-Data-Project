[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared #"stg nyctaxi_yellow" = let
  Джерело = Fabric.Warehouse(null),
  Навігація = Джерело{[workspaceId = "298604c0-147d-4376-aa69-eb45754f28df"]}[Data],
  #"Навігація 1" = Навігація{[warehouseId = "fc6b09fd-3e52-4385-b51b-a23a0ed3ad1b"]}[Data],
  #"Навігація 2" = #"Навігація 1"{[Schema = "stg", Item = "nyctaxi_yellow"]}[Data],
  #"Видалено стовпці" = Table.RemoveColumns(#"Навігація 2", {"RatecodeID", "store_and_fwd_flag", "fare_amount", "extra", "mta_tax", "tip_amount", "tolls_amount", "improvement_surcharge", "congestion_surcharge", "Airport_fee"})
in
  #"Видалено стовпці";
