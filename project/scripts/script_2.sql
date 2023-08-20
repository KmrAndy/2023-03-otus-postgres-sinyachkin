truncate project_schema.drop_table_partitions;
truncate project_schema.archive_table_partitions;
truncate project_schema.create_table_partitions;

insert into project_schema.drop_table_partitions(table_owner,      table_name,             stored_partition_quantity, enabled, search_type)
                                          values('project_schema', 'logs',                 5,                         'Y',     1),
                                                ('project_schema', 'list_table',           5,                         'Y',     1),
                                                ('project_schema', 'list_table_growthkey', 5,                         'Y',     2),
                                                ('project_schema', 'unexpected_table',     5,                         'Y',     2);

insert into project_schema.archive_table_partitions(table_owner,      table_name,             archive_table_name,           stored_partition_quantity, enabled, search_type)
                                             values('project_schema', 'logs',                 'arch_logs',                  3,                         'Y',     1),
                                                   ('project_schema', 'list_table',           'arch_list_table',            3,                         'Y',     1),
                                                   ('project_schema', 'list_year_table',      'arch_list_year_table',       1,                         'Y',     2),
                                                   ('project_schema', 'list_table_growthkey', 'arch_list_table_growthkey',  2,                         'Y',     2),
                                                   ('project_schema', 'unexpected_table',     'arch_unexpected_table',      5,                         'Y',     2);

insert into project_schema.create_table_partitions(table_owner,      table_name,             stored_partition_quantity, enabled, search_type, partition_interval)
                                            values('project_schema', 'logs',                 10,                        'Y',     1,           'MONTH'),
                                                  ('project_schema', 'list_table',           24,                        'Y',     2,           'DAY'),
                                                  ('project_schema', 'list_year_table',      2,                         'Y',     1,           'YEAR'),
                                                  ('project_schema', 'unexpected_table',     5,                         'Y',     2,           'DAY');
commit;