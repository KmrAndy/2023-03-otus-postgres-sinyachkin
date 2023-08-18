reset default_tablespace;

drop table if exists project_schema.list_table_growthkey;
create table project_schema.list_table_growthkey
(
    field_id      bigint not null,
    field_partkey int not null,
    field_1       timestamp not null,
    field_2       varchar(256),
    field_3       integer
) partition by list(field_partkey);

create index list_table_growthkey_ui1 on project_schema.list_table_growthkey(field_id, field_partkey);

create table project_schema.list_table_growthkey_1  partition of project_schema.list_table_growthkey for values in (1);
create table project_schema.list_table_growthkey_2  partition of project_schema.list_table_growthkey for values in (2);
create table project_schema.list_table_growthkey_3  partition of project_schema.list_table_growthkey for values in (3);
create table project_schema.list_table_growthkey_4  partition of project_schema.list_table_growthkey for values in (4);
create table project_schema.list_table_growthkey_5  partition of project_schema.list_table_growthkey for values in (5);
create table project_schema.list_table_growthkey_6  partition of project_schema.list_table_growthkey for values in (6);
create table project_schema.list_table_growthkey_7  partition of project_schema.list_table_growthkey for values in (7);
create table project_schema.list_table_growthkey_8  partition of project_schema.list_table_growthkey for values in (8);
create table project_schema.list_table_growthkey_9  partition of project_schema.list_table_growthkey for values in (9);
create table project_schema.list_table_growthkey_10 partition of project_schema.list_table_growthkey for values in (10);
