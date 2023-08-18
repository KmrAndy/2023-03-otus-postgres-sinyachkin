insert into project_schema.drop_table_partitions(table_owner, table_name, stored_partition_quantity, enabled, search_type)
values('project_schema', 'logs', 10, 'Y', 1);
insert into project_schema.drop_table_partitions(table_owner, table_name, stored_partition_quantity, enabled, search_type)
values('project_schema', 'list_table', 5, 'Y', 1);
insert into project_schema.drop_table_partitions(table_owner, table_name, stored_partition_quantity, enabled, search_type)
values('project_schema', 'list_table_growthkey', 5, 'Y', 2);
commit;