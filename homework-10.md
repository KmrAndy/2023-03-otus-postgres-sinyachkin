# Домашнее задание
## Репликация

### Цель:
- реализовать свой миникластер на 3 ВМ

### Описание/Пошаговая инструкция выполнения домашнего задания:
_Создал 3 ВМ в ЯО._
```
postgres1 158.160.46.55
postgres2 84.201.156.14
postgres3 158.160.54.255
```
1) На 1 ВМ создаем таблицы test для записи, test2 для запросов на чтение.
```sql
kmrandy@postgres1:~$ sudo -u postgres psql
could not change directory to "/home/kmrandy": Permission denied
psql (15.3 (Ubuntu 15.3-1.pgdg22.04+1))
Type "help" for help.

postgres=# create database testdb1;
CREATE DATABASE
postgres=# \c testdb1
You are now connected to database "testdb1" as user "postgres".
testdb1=# create table test(id integer, object_name char(30));
CREATE TABLE
testdb1=# create table test2(id integer, object2_name char(30));
CREATE TABLE
```
```sql
testdb1=# ALTER SYSTEM SET wal_level = logical;
ALTER SYSTEM
testdb1=# exit
kmrandy@postgres1:~$ sudo pg_ctlcluster 15 main1 restart
kmrandy@postgres1:~$ sudo -u postgres psql
could not change directory to "/home/kmrandy": Permission denied
psql (15.3 (Ubuntu 15.3-1.pgdg22.04+1))
Type "help" for help.

postgres=# \c testdb1
You are now connected to database "testdb1" as user "postgres".
testdb1=# show wal_level;
 wal_level
-----------
 logical
(1 row)
```
2) Создаем публикацию таблицы test и подписываемся на публикацию таблицы test2 с ВМ №2.
_Долго бился с настройками доступов между двумя ВМ._
_В итоге на всех ВМ в postgresql.conf поставил listen_address = '0.0.0.0'._ 
_В pg_hba.conf добавил строчку:_
```
host  all  all 0.0.0.0/0 md5

```

_На всех ВМ включил wal_level = 'replica'._
_На всех ВМ создал Базы:_
```
postrges1 - testdb1
postrges2 - testdb2
postrges3 - testdb3
```
_После этого подписка создалась, но с ошибкой, что публикации на 2 ВМ пока нет._

```sql
testdb1=# CREATE PUBLICATION test_pub FOR TABLE test;
CREATE PUBLICATION
testdb1=# \dRp+
                            Publication test_pub
  Owner   | All tables | Inserts | Updates | Deletes | Truncates | Via root
----------+------------+---------+---------+---------+-----------+----------
 postgres | f          | t       | t       | t       | t         | f
Tables:
    "public.test"
	
testdb1=# create subscription test2_sub connection 'host=84.201.156.14 port=5432 user=postgres password=pass123 dbname=testdb2' PUBLICATION test2_pub WITH (copy_data = true);
WARNING:  publication "test2_pub" does not exist on the publisher
NOTICE:  created replication slot "test2_sub" on publisher
CREATE SUBSCRIPTION
testdb1=#
```
3) На 2 ВМ создаем таблицы test2 для записи, test для запросов на чтение.
_Cоздаем таблицы на 2 ВМ:_
```sql
postgres=# \c testdb2
You are now connected to database "testdb2" as user "postgres".
testdb2=# create table test(id integer, object_name char(30));
CREATE TABLE
testdb2=# create table test2(id integer, object2_name char(30));
CREATE TABLE
```
4) Создаем публикацию таблицы test2 и подписываемся на публикацию таблицы test1 с ВМ №1.
_Теперь создаем публикацию и обратную подписку на 2 ВМ:_
```
testdb2=# CREATE PUBLICATION test2_pub FOR TABLE test2;
CREATE PUBLICATION
testdb2=# \dRp+
                           Publication test2_pub
  Owner   | All tables | Inserts | Updates | Deletes | Truncates | Via root
----------+------------+---------+---------+---------+-----------+----------
 postgres | f          | t       | t       | t       | t         | f
Tables:
    "public.test2"

testdb2=# create subscription test_sub connection 'host=158.160.46.55 port=5432 user=postgres password=pass123 dbname=te
stdb1' PUBLICATION test_pub WITH (copy_data = true);
NOTICE:  created replication slot "test_sub" on publisher
CREATE SUBSCRIPTION
```

_Проверка:_
_В обеих ВМ нет записей в таблицах test и test2:_
```sql
testdb1=# select * from test;
 id | object_name
----+-------------
(0 rows)

testdb1=# select * from test2;
 id | object2_name
----+--------------
(0 rows)
```
```sql
testdb2=# select * from test;
 id | object_name
----+-------------
(0 rows)

testdb2=# select * from test2;
 id | object2_name
----+--------------
(0 rows)
```

_На 1 ВМ добавим запись в таблицу test, на 2 ВМ добавим запись в таблицу test2:_
```sql
testdb1=# insert into test values(1, 'test_obj1');
INSERT 0 1
```

```sql
testdb2=# insert into test2 values(1, 'test_obj2');
INSERT 0 1
```

_Записи появились во всех таблицах обеих ВМ:_
```sql
testdb1=# select * from test;
 id |          object_name
----+--------------------------------
  1 | test_obj1
(1 row)

testdb1=# select * from test2;
 id |          object2_name
----+--------------------------------
  1 | test_obj2
(1 row)
```

```sql
testdb2=# select * from test;
 id |          object_name
----+--------------------------------
  1 | test_obj1
(1 row)

testdb2=# select * from test2;
 id |          object2_name
----+--------------------------------
  1 | test_obj2
(1 row)
```

5) 3 ВМ использовать как реплику для чтения и бэкапов (подписаться на таблицы из ВМ №1 и №2 ).
_Создаем таблицы и подписки на 3 ВМ:_
```sql
testdb3=# create table test(id integer, object_name char(30));
CREATE TABLE
testdb3=# create table test2(id integer, object2_name char(30));
CREATE TABLE
testdb3=# create subscription test_sub_repl connection 'host=158.160.46.55 port=5432 user=postgres password=pass123 dbname=testdb1' PUBLICATION test_pub WITH (copy_data = true);
NOTICE:  created replication slot "test_sub_repl" on publisher
CREATE SUBSCRIPTION
testdb3=# create subscription test2_sub_repl connection 'host=84.201.156.14 port=5432 user=postgres password=pass123 dbname=testdb2' PUBLICATION test2_pub WITH (copy_data = true);
NOTICE:  created replication slot "test2_sub_repl" on publisher
CREATE SUBSCRIPTION
```

_Проверим, что данные в таблицах на 3 ВМ появились:_
```sql
testdb3=# select * from test;
 id |          object_name
----+--------------------------------
  1 | test_obj1
(1 row)

testdb3=# select * from test2;
 id |          object2_name
----+--------------------------------
  1 | test_obj2
(1 row)
```

6) Задачка под звездочкой: реализовать горячее реплицирование для высокой доступности на 4ВМ. Источником должна выступать ВМ №3. Написать с какими проблемами столкнулись.