# Домашнее задание
## Работа с базами данных, пользователями и правами

### Цель:
- создание новой базы данных, схемы и таблицы
- создание роли для чтения данных из созданной схемы созданной базы данных
- создание роли для чтения и записи из созданной схемы созданной базы данных

### Описание/Пошаговая инструкция выполнения домашнего задания:
1) создайте новый кластер PostgresSQL 14
_Создал кластер_
```
sudo apt update && sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y -q && sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - && sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt -y install postgresql-14
```
2) зайдите в созданный кластер под пользователем postgres
```
sudo -u postgres psql
```
3) создайте новую базу данных testdb
```sql
CREATE DATABASE testdb;
```
4) зайдите в созданную базу данных под пользователем postgres
```
\c testdb postgres
```
5) создайте новую схему testnm
```sql
CREATE SCHEMA testnm;
```
6) создайте новую таблицу t1 с одной колонкой c1 типа integer
```sql
CREATE TABLE testnm.t1 (c1 integer);
```
7) вставьте строку со значением c1=1
_Работает автокоммит_
```sql
INSERT INTO testnm.t1 (c1) VALUES (1);
```
8) создайте новую роль readonly
```sql
CREATE ROLE readonly;
```
9) дайте новой роли право на подключение к базе данных testdb
```sql
GRANT CONNECT ON DATABASE testdb TO readonly;
```
10) дайте новой роли право на использование схемы testnm
```sql
GRANT USAGE ON SCHEMA testnm TO readonly;
```
11) дайте новой роли право на select для всех таблиц схемы testnm
```sql
GRANT SELECT ON ALL TABLES IN SCHEMA testnm TO readonly;
```
12) создайте пользователя testread с паролем test123
```sql
CREATE USER testread with password 'test123';
```
13) дайте роль readonly пользователю testread
```sql
GRANT readonly TO testread; 
```
14) зайдите под пользователем testread в базу данных testdb
```
\c testdb testread
```
_Получил ошибку FATAL:  Peer authentication failed for user "testread". Погуглив в инете и заглянув в подсказку, нашел решение_
```
testdb=# \q
kmrandy@postgres:~$ psql -h 127.0.0.1 -U testread -d testdb -W
Password:
psql (14.7 (Ubuntu 14.7-1.pgdg22.04+1))
SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, bits: 256, compression: off)
Type "help" for help.

testdb=>
```
15) сделайте select * from t1;
```sql
SELECT * FROM t1;
```
16) получилось? (могло если вы делали сами не по шпаргалке и не упустили один существенный момент про который позже)
_Ошибка ERROR:  relation "t1" does not exist_
17) напишите что именно произошло в тексте домашнего задания
_Без указания схемы таблицы её поиск производился в схеме подключенного юзера и public, где такой таблицы нет_
```
 show search_path ;
   search_path
-----------------
 "$user", public
(1 row)
```
18) у вас есть идеи почему? ведь права то дали?
_Нужно сделать указание конкретной схемы testnm для таблицы t1, либо добавить схему testnm в search_path для пользователя testread_
19) посмотрите на список таблиц
```
testdb=> \dt
Did not find any relations.
```
20) подсказка в шпаргалке под пунктом 20
_Так сработало:_
```sql
testdb=> SELECT * FROM testnm.t1;
 c1
----
  1
(1 row)
```
21) а почему так получилось с таблицей (если делали сами и без шпаргалки то может у вас все нормально)
```
Если не указывать схему при создании таблицы, то она попадет в public, так как схемы postgres нет
```
22) вернитесь в базу данных testdb под пользователем postgres
```
Пропускаю этот шаг, так как изначально создавал с явным указанием схемы
```
23) удалите таблицу t1
```
Пропускаю этот шаг, так как изначально создавал с явным указанием схемы
```
24) создайте ее заново но уже с явным указанием имени схемы testnm
```
Пропускаю этот шаг, так как изначально создавал с явным указанием схемы
```
25) вставьте строку со значением c1=1
```
Пропускаю этот шаг, так как изначально создавал с явным указанием схемы
```
26) зайдите под пользователем testread в базу данных testdb
```
Пропускаю этот шаг, так как изначально создавал с явным указанием схемы
```
27) сделайте select * from testnm.t1;
```sql
testdb=> SELECT * FROM testnm.t1;
 c1
----
  1
(1 row)
```
28) получилось?
_Да_
29) есть идеи почему? если нет - смотрите шпаргалку
_Теперь таблица была найдена через явное указание схемы и права на её SELECT у пользователя testread есть_
30) как сделать так чтобы такое больше не повторялось? если нет идей - смотрите шпаргалку
_Установить search_path с указанием схемы_
```sql
SET search_path TO testnm,public;
```
31) сделайте select * from testnm.t1;
```sql
testdb=> SELECT * FROM testnm.t1;
 c1
----
  1
(1 row)
```
32) получилось?
_Да, теперь можно и без указания схемы_
```
testdb=> SELECT * FROM t1;
 c1
----
  1
(1 row)
```
33) есть идеи почему? если нет - смотрите шпаргалку
_У меня всё получилось_
31) сделайте select * from testnm.t1;
_У меня всё получилось_
32) получилось?
_У меня всё получилось_
33) ура!
34) теперь попробуйте выполнить команду create table t2(c1 integer); insert into t2 values (2);
```
testdb=> create table t2(c1 integer);
ERROR:  permission denied for schema testnm
LINE 1: create table t2(c1 integer);
```
35) а как так? нам же никто прав на создание таблиц и insert в них под ролью readonly?
_Прав нет, возможно в вашем примере таблица создавалась в public, но я изменил search_path и таблица должна была создаться в схеме testnm, на которую у пользователя testread нет таких прав_
36) есть идеи как убрать эти права? если нет - смотрите шпаргалку
_Установить корректный search_path_
37) если вы справились сами то расскажите что сделали и почему, если смотрели шпаргалку - объясните что сделали и почему выполнив указанные в ней команды
_Проверив шпаргалку действительно таблица создавалась в public, поэтому команды выполнялись_
38) теперь попробуйте выполнить команду create table t3(c1 integer); insert into t2 values (2);
39) расскажите что получилось и почему
_Будет аналогичная ошибка из пункта 34_