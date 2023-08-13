drop table if exists project_schema.logs;
create table project_schema.logs
(
    log_id      bigint primary key default nextval('project_schema.s_logs'),
    log_date    timestamp not null default localtimestamp,
    username    varchar(128) not null default current_user,
    pid         integer not null default pg_backend_pid(),
    message     varchar(1000) not null,
    stacktrace  varchar(4000)
);