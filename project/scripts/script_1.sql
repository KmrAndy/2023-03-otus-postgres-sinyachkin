-- Создаём БД project_main_db
create database project_main_db;

--Подключаемся к БД project_main_db
-- Выполняем дальнейшие шаги
drop schema if exists project_schema cascade;
create schema project_schema;

drop schema if exists maintenance_schema cascade;
create schema maintenance_schema;

set search_path = project_schema, maintenance_schema, public;

--создать папки на сервере
/var/lib/postgresql/15/main/data/tblspaces/tblspace202301
/var/lib/postgresql/15/main/data/tblspaces/tblspace202302
/var/lib/postgresql/15/main/data/tblspaces/tblspace202303
/var/lib/postgresql/15/main/data/tblspaces/tblspace202304
/var/lib/postgresql/15/main/data/tblspaces/tblspace202305
/var/lib/postgresql/15/main/data/tblspaces/tblspace202306
/var/lib/postgresql/15/main/data/tblspaces/tblspace202307
/var/lib/postgresql/15/main/data/tblspaces/tblspace202308
/var/lib/postgresql/15/main/data/tblspaces/tblspace202309
/var/lib/postgresql/15/main/data/tblspaces/tblspace202310
/var/lib/postgresql/15/main/data/tblspaces/tblspace202311
/var/lib/postgresql/15/main/data/tblspaces/tblspace202312

-- создаем табличные пространства
create tablespace tblspace202301 location '/var/lib/postgresql/15/main/data/tblspaces/tblspace202301';
create tablespace tblspace202302 location '/var/lib/postgresql/15/main/data/tblspaces/tblspace202302';
create tablespace tblspace202303 location '/var/lib/postgresql/15/main/data/tblspaces/tblspace202303';
create tablespace tblspace202304 location '/var/lib/postgresql/15/main/data/tblspaces/tblspace202304';
create tablespace tblspace202305 location '/var/lib/postgresql/15/main/data/tblspaces/tblspace202305';
create tablespace tblspace202306 location '/var/lib/postgresql/15/main/data/tblspaces/tblspace202306';
create tablespace tblspace202307 location '/var/lib/postgresql/15/main/data/tblspaces/tblspace202307';
create tablespace tblspace202308 location '/var/lib/postgresql/15/main/data/tblspaces/tblspace202308';
create tablespace tblspace202309 location '/var/lib/postgresql/15/main/data/tblspaces/tblspace202309';
create tablespace tblspace202310 location '/var/lib/postgresql/15/main/data/tblspaces/tblspace202310';
create tablespace tblspace202311 location '/var/lib/postgresql/15/main/data/tblspaces/tblspace202311';
create tablespace tblspace202312 location '/var/lib/postgresql/15/main/data/tblspaces/tblspace202312';