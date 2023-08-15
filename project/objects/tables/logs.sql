reset default_tablespace;

drop table if exists project_schema.logs;
create table project_schema.logs
(
    log_id      bigint default nextval('project_schema.s_logs'),
    log_date    timestamp not null default localtimestamp,
    username    varchar(128) not null default current_user,
    pid         integer not null default pg_backend_pid(),
    message     varchar(1000) not null,
    stacktrace  varchar(4000)
) partition by range(log_date);

alter table project_schema.logs add constraint logs_pkey primary key(log_id, log_date);

set default_tablespace = tblspace202301;
create table project_schema.logs_202301 partition of project_schema.logs for values from ('2023-01-01'::timestamp) to ('2023-02-01'::timestamp) tablespace tblspace202301;
set default_tablespace = tblspace202302;
create table project_schema.logs_202302 partition of project_schema.logs for values from ('2023-02-01'::timestamp) to ('2023-03-01'::timestamp) tablespace tblspace202302;
set default_tablespace = tblspace202303;
create table project_schema.logs_202303 partition of project_schema.logs for values from ('2023-03-01'::timestamp) to ('2023-04-01'::timestamp) tablespace tblspace202303;
set default_tablespace = tblspace202304;
create table project_schema.logs_202304 partition of project_schema.logs for values from ('2023-04-01'::timestamp) to ('2023-05-01'::timestamp) tablespace tblspace202304;
set default_tablespace = tblspace202305;
create table project_schema.logs_202305 partition of project_schema.logs for values from ('2023-05-01'::timestamp) to ('2023-06-01'::timestamp) tablespace tblspace202305;
set default_tablespace = tblspace202306;
create table project_schema.logs_202306 partition of project_schema.logs for values from ('2023-06-01'::timestamp) to ('2023-07-01'::timestamp) tablespace tblspace202306;
set default_tablespace = tblspace202307;
create table project_schema.logs_202307 partition of project_schema.logs for values from ('2023-07-01'::timestamp) to ('2023-08-01'::timestamp) tablespace tblspace202307;
set default_tablespace = tblspace202308;
create table project_schema.logs_202308 partition of project_schema.logs for values from ('2023-08-01'::timestamp) to ('2023-09-01'::timestamp) tablespace tblspace202308;
set default_tablespace = tblspace202309;
create table project_schema.logs_202309 partition of project_schema.logs for values from ('2023-09-01'::timestamp) to ('2023-10-01'::timestamp) tablespace tblspace202309;
set default_tablespace = tblspace202310;
create table project_schema.logs_202310 partition of project_schema.logs for values from ('2023-10-01'::timestamp) to ('2023-11-01'::timestamp) tablespace tblspace202310;
set default_tablespace = tblspace202311;
create table project_schema.logs_202311 partition of project_schema.logs for values from ('2023-11-01'::timestamp) to ('2023-12-01'::timestamp) tablespace tblspace202311;
set default_tablespace = tblspace202312;
create table project_schema.logs_202312 partition of project_schema.logs for values from ('2023-12-01'::timestamp) to ('2024-01-01'::timestamp) tablespace tblspace202312;

reset default_tablespace;

create table project_schema.logs_202401
partition of project_schema.logs
for values from ('2024-01-01'::timestamp) to ('2024-02-01'::timestamp) partition by range(log_date);

create table project_schema.logs_202401_sp1
partition of project_schema.logs_202401
for values from ('2024-01-01') to ('2024-01-02');
 
create table project_schema.logs_202401_spdefault
partition of project_schema.logs_202401
for values from ('2024-01-02') to ('2024-02-01');

