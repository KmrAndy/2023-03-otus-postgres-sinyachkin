reset default_tablespace;

drop table if exists project_schema.list_table;
create table project_schema.list_table
(
    field_id      bigint not null,
    field_partkey int not null,
    field_1       timestamp not null,
    field_2       varchar(256) not null,
    field_3       integer not null
) partition by list(field_partkey);

create index list_table_i1 on project_schema.list_table(field_3);

set default_tablespace = tblspace202301;
create table project_schema.list_table_202301 partition of project_schema.list_table for values in (20230101) tablespace tblspace202301;
set default_tablespace = tblspace202302;
create table project_schema.list_table_202302 partition of project_schema.list_table for values in (20230201) tablespace tblspace202302;
set default_tablespace = tblspace202303;
create table project_schema.list_table_202303 partition of project_schema.list_table for values in (20230301) tablespace tblspace202303;
set default_tablespace = tblspace202304;
create table project_schema.list_table_202304 partition of project_schema.list_table for values in (20230401) tablespace tblspace202304;
set default_tablespace = tblspace202305;
create table project_schema.list_table_202305 partition of project_schema.list_table for values in (20230501) tablespace tblspace202305;
set default_tablespace = tblspace202306;
create table project_schema.list_table_202306 partition of project_schema.list_table for values in (20230601) tablespace tblspace202306;
set default_tablespace = tblspace202307;
create table project_schema.list_table_202307 partition of project_schema.list_table for values in (20230701) tablespace tblspace202307;
set default_tablespace = tblspace202308;
create table project_schema.list_table_202308 partition of project_schema.list_table for values in (20230801) tablespace tblspace202308;
set default_tablespace = tblspace202309;
create table project_schema.list_table_202309 partition of project_schema.list_table for values in (20230901) tablespace tblspace202309;
set default_tablespace = tblspace202310;
create table project_schema.list_table_202310 partition of project_schema.list_table for values in (20231001) tablespace tblspace202310;
set default_tablespace = tblspace202311;
create table project_schema.list_table_202311 partition of project_schema.list_table for values in (20231101) tablespace tblspace202311;
set default_tablespace = tblspace202312;
create table project_schema.list_table_202312 partition of project_schema.list_table for values in (20231201) tablespace tblspace202312;

reset default_tablespace;
