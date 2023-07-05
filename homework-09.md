# Домашнее задание
## Бэкапы

### Цель:
- Применить логический бэкап
- Восстановиться из бэкапа

### Описание/Пошаговая инструкция выполнения домашнего задания:
1) Создаем ВМ/докер c ПГ.
_Создал ВМ в ЯО. Установил PG 15:_
```
sudo apt update && sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y -q && sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - && sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt -y install postgresql-15
```
2) Создаем БД, схему и в ней таблицу.
```sql
postgres=# create database test;
CREATE DATABASE
postgres=# \c test;
You are now connected to database "test" as user "postgres".
test=# create schema test_schema;
CREATE SCHEMA
test=# create table test_schema.test_table(id int, object_name char(20));
CREATE TABLE
```
3) Заполним таблицы автосгенерированными 100 записями.
```sql
test=# INSERT INTO test_schema.test_table(id, object_name) SELECT generate_series(1,100), md5(random()::text)::char(20);
INSERT 0 100
```
4) Под линукс пользователем Postgres создадим каталог для бэкапов
_Создадим папку /etc/postgresql/pg_backups_
```
postgres@postgres:/etc/postgresql$ mkdir pg_backups
postgres@postgres:/etc/postgresql$ ls -l
total 8
drwxr-xr-x 3 postgres postgres 4096 Jul  3 18:52 15
drwxrwxr-x 2 postgres postgres 4096 Jul  3 19:12 pg_backups
```
5) Сделаем логический бэкап используя утилиту COPY
_Создаем логический бекап test_table_backup.sql_
```sql
test=# \copy test_schema.test_table to '/etc/postgresql/pg_backups/test_table_backup.sql';
COPY 100
```
6) Восстановим во вторую таблицу данные из бэкапа.
_Создадим таблицу test_schema.test_table_backup_
```sql
test=# create table test_schema.test_table_backup(id int, object_name char(20));
CREATE TABLE
test=# select count(1) from test_schema.test_table_backup;
 count
-------
     0
(1 row)
```
_Восстановим в неё данные из бекапа таблицы test_schema.test_table_
```sql
test=# \copy test_schema.test_table_backup from '/etc/postgresql/pg_backups/test_table_backup.sql';
COPY 100
test=# select count(1) from test_schema.test_table_backup;
 count
-------
   100
(1 row)
```
7) Используя утилиту pg_dump создадим бэкап в кастомном сжатом формате двух таблиц
_Создадим бекап arch_backup.gz_
```
postgres@postgres:/etc/postgresql/pg_backups$ pg_dump -d test --create -U postgres -Fc > /etc/postgresql/pg_backups/arch_backup.gz
postgres@postgres:/etc/postgresql/pg_backups$ ls -l
total 12
-rw-rw-r-- 1 postgres postgres 5299 Jul  3 19:25 arch_backup.gz
-rw-rw-r-- 1 postgres postgres 2392 Jul  3 19:15 test_table_backup.sql
```
8) Используя утилиту pg_restore восстановим в новую БД только вторую таблицу!
_Дропнем базу test и создадим её и схему заново_
```sql
postgres=# drop database test;
DROP DATABASE
postgres=# create database test;
CREATE DATABASE
postgres=# \c test
You are now connected to database "test" as user "postgres".
test=# create schema test_schema;
CREATE SCHEMA
```
_Восстановим из бекапа только таблицу test_schema.test_table_backup. Для этого передадим дополнительные параметры команды pg_restore для указания схемы и таблицы_ 
```
postgres@postgres:/etc/postgresql/pg_backups$ pg_restore -d test -U postgres -n test_schema -t test_table_backup /etc/postgresql/pg_backups/arch_backup.gz
```
_Проверим, что восстановилась только она_
```
postgres=# \c test
You are now connected to database "test" as user "postgres".
test=# select count(1) from test_schema.test_table_backup;
 count
-------
   100
(1 row)

test=# select count(1) from test_schema.test_table;
ERROR:  relation "test_schema.test_table" does not exist
LINE 1: select count(1) from test_schema.test_table;
```