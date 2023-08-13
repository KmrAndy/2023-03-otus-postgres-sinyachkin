-- Создаём БД project_main_db
create database project_main_db;

--Подключаемся к БД project_main_db
-- Выполняем дальнейшие шаги
drop schema if exists project_schema cascade;
create schema project_schema;

drop schema if exists maintenance_schema cascade;
create schema maintenance_schema;

set search_path = project_schema, maintenance_schema, public;