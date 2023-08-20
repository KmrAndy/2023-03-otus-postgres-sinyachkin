reset default_tablespace;

drop table if exists project_schema.arch_list_table;
create table project_schema.arch_list_table
(
    field_id      bigint not null,
    field_partkey int not null,
    field_1       timestamp not null,
    field_2       varchar(256) not null,
    field_3       integer not null
) partition by list(field_partkey);

create index arch_list_table_i1 on project_schema.arch_list_table(field_3);
