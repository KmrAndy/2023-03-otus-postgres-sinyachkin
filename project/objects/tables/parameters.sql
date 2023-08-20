reset default_tablespace;

drop table if exists project_schema.parameters;
create table project_schema.parameters
(
    module varchar(32) not null,
    param  varchar(32) not null,
    value  varchar(32),
    primary key (module, param)
);