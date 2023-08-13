-- таблица для настройки удаления старых партиций
drop table if exists project_schema.drop_table_partitions;
create table project_schema.drop_table_partitions
(
    table_owner               varchar(128) not null,
    table_name                varchar(128) not null,
    stored_partition_quantity integer not null,
    enabled                   varchar(1) not null default 'N',
    search_type               integer not null
);
