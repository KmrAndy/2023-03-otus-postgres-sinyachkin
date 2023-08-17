drop type if exists maintenance_schema.partition_params;
create type maintenance_schema.partition_params as (partition_name varchar(128)
                                                  , table_owner    varchar(128)
                                                  , table_name     varchar(128));