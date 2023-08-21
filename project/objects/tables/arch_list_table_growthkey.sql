reset default_tablespace;

drop table if exists project_schema.arch_list_table_growthkey;
create table project_schema.arch_list_table_growthkey
(
    field_id      bigint not null,
    field_partkey int not null,
    field_1       timestamp not null,
    field_2       varchar(256),
    field_3       integer
) partition by list(field_partkey);

create index arch_list_table_growthkey_ui1 on project_schema.arch_list_table_growthkey(field_id, field_partkey);