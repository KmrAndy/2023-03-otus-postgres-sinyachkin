reset default_tablespace;

drop table if exists project_schema.list_year_table;
create table project_schema.list_year_table
(
    field_id      bigint not null,
    field_partkey int not null,
    field_1       timestamp not null,
    field_2       varchar(256) not null,
    field_3       integer not null
) partition by list(field_partkey);

create index list_year_table_i1 on project_schema.list_year_table(field_3);

set default_tablespace = pg_default;
create table project_schema.list_year_table_2022 partition of project_schema.list_year_table for values in (20221231);
set default_tablespace = tblspace202312;
create table project_schema.list_year_table_2023 partition of project_schema.list_year_table for values in (20231231) tablespace tblspace202312;

reset default_tablespace;