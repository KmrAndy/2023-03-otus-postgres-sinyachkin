reset default_tablespace;

drop table if exists project_schema.archiever_queue;
create table project_schema.archiever_queue
(
    id             serial,
    queue_date     timestamp not null default localtimestamp,
    table_owner    varchar(128) not null,
    table_name     varchar(128) not null,
    partition_name varchar(128) not null,
    process_flag   int,
    process_date   timestamp
) partition by range(queue_date);

alter table project_schema.archiever_queue add constraint archiever_queue_pkey primary key(id, queue_date);
create index archiever_queue_i1 on project_schema.archiever_queue(process_flag);

create table project_schema.archiever_queue_202301 partition of project_schema.archiever_queue for values from ('2023-01-01'::timestamp) to ('2023-02-01'::timestamp);
create table project_schema.archiever_queue_202302 partition of project_schema.archiever_queue for values from ('2023-02-01'::timestamp) to ('2023-03-01'::timestamp);
create table project_schema.archiever_queue_202303 partition of project_schema.archiever_queue for values from ('2023-03-01'::timestamp) to ('2023-04-01'::timestamp);
create table project_schema.archiever_queue_202304 partition of project_schema.archiever_queue for values from ('2023-04-01'::timestamp) to ('2023-05-01'::timestamp);
create table project_schema.archiever_queue_202305 partition of project_schema.archiever_queue for values from ('2023-05-01'::timestamp) to ('2023-06-01'::timestamp);
create table project_schema.archiever_queue_202306 partition of project_schema.archiever_queue for values from ('2023-06-01'::timestamp) to ('2023-07-01'::timestamp);
create table project_schema.archiever_queue_202307 partition of project_schema.archiever_queue for values from ('2023-07-01'::timestamp) to ('2023-08-01'::timestamp);
create table project_schema.archiever_queue_202308 partition of project_schema.archiever_queue for values from ('2023-08-01'::timestamp) to ('2023-09-01'::timestamp);
create table project_schema.archiever_queue_202309 partition of project_schema.archiever_queue for values from ('2023-09-01'::timestamp) to ('2023-10-01'::timestamp);
create table project_schema.archiever_queue_202310 partition of project_schema.archiever_queue for values from ('2023-10-01'::timestamp) to ('2023-11-01'::timestamp);
create table project_schema.archiever_queue_202311 partition of project_schema.archiever_queue for values from ('2023-11-01'::timestamp) to ('2023-12-01'::timestamp);
create table project_schema.archiever_queue_202312 partition of project_schema.archiever_queue for values from ('2023-12-01'::timestamp) to ('2024-01-01'::timestamp);