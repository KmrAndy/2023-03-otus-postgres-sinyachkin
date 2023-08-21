reset default_tablespace;

drop table if exists project_schema.arch_logs;
create table project_schema.arch_logs
(
    log_id      bigint not null,
    log_date    timestamp not null,
    username    varchar(128) not null,
    pid         integer not null,
    message     varchar(1000) not null,
    stacktrace  varchar(4000)
) partition by range(log_date);

alter table project_schema.arch_logs add constraint arch_logs_pkey primary key(log_id, log_date);