# Домашнее задание
## Работа с индексами, join'ами, статистикой

### Цель:
- знать и уметь применять основные виды индексов PostgreSQL
- строить и анализировать план выполнения запроса
- уметь оптимизировать запросы для с использованием индексов
- знать и уметь применять различные виды join'ов
- строить и анализировать план выполенения запроса
- оптимизировать запрос
- уметь собирать и анализировать статистику для таблицы

### Описание/Пошаговая инструкция выполнения домашнего задания:
1 вариант:
Создать индексы на БД, которые ускорят доступ к данным.
В данном задании тренируются навыки:

- определения узких мест
- написания запросов для создания индекса
- оптимизации
Необходимо:
1) Создать индекс к какой-либо из таблиц вашей БД
2) Прислать текстом результат команды explain, в которой используется данный индекс
3) Реализовать индекс для полнотекстового поиска
4) Реализовать индекс на часть таблицы или индекс на поле с функцией
5) Создать индекс на несколько полей
6) Написать комментарии к каждому из индексов
7) Описать что и как делали и с какими проблемами столкнулись
_Создал ВМ в ЯО, Установил 15 Постгрес._
_Создал БД testdb. Создал таблицу test_table с 1 миллионом сгенерированных записей.
```sql
create table test_table as 
select 
  generate_series(1,1000000) as id,
  md5(random()::text)::char(10) as serial_number;
```
_План запроса к таблице без индексов:_
```sql
 explain
 select * from test_table where id = 1000;

QUERY PLAN                                                         |
-------------------------------------------------------------------+
Seq Scan on test_table  (cost=0.00..15406.00 rows=1000000 width=15)|
```
_1) Создадим уникальный индекс по колонке id_
```
create unique index test_table_ui01 on test_table(id);
```
_2) Теперь используется индекс при фильтрации по id:_
```sql
 explain
 select * from test_table where id = 1000;

QUERY PLAN                                                                       |
---------------------------------------------------------------------------------+
Index Scan using test_table_ui01 on test_table  (cost=0.42..8.44 rows=1 width=15)|
  Index Cond: (id = 1000)                                                        |
```
_3) Добавим колонку serial_number_tsvector типа tsvector для полнотекстового поиска и создадим индекс по этому полю:_
```sql
alter table test_table add column serial_number_tsvector tsvector;

update test_table set serial_number_tsvector = to_tsvector(serial_number);

create index test_table_gin_i01 ON test_table using gin (serial_number_tsvector);
```
_Индекс стал использоваться для фильтрации по полю serial_number_tsvector:_
```sql
explain
select *
from test_table
where serial_number_tsvector @@ to_tsquery('0ba39e929a');

QUERY PLAN                                                                       |
---------------------------------------------------------------------------------+
Bitmap Heap Scan on test_table  (cost=20.51..156.33 rows=33 width=38)            |
  Recheck Cond: (serial_number_tsvector @@ to_tsquery('0ba39e929a'::text))       |
  ->  Bitmap Index Scan on test_table_gin_i01  (cost=0.00..20.50 rows=33 width=0)|
        Index Cond: (serial_number_tsvector @@ to_tsquery('0ba39e929a'::text))   |
```
_4) Пересоздадим уникальный индекс, но с условием, что в него попадут только id < 100:_
```sql
drop index test_table_ui01;
create unique index test_table_ui01 on test_table(id) where id < 100;
```
_При запросе к таблице с фильтром id = 99 индекс работает, а при запросе с id = 101 - нет:_
```sql
explain
select * from test_table where id = 99;

QUERY PLAN                                                                       |
---------------------------------------------------------------------------------+
Index Scan using test_table_ui01 on test_table  (cost=0.14..8.16 rows=1 width=38)|
  Index Cond: (id = 99)                                                          |
  
explain
select * from test_table where id = 101;

QUERY PLAN                                                                  |
----------------------------------------------------------------------------+
Gather  (cost=1000.00..20026.43 rows=1 width=38)                            |
  Workers Planned: 2                                                        |
  ->  Parallel Seq Scan on test_table  (cost=0.00..19026.33 rows=1 width=38)|
        Filter: (id = 101)                                                  |
```
_5) Создадим индекс на 2 поля id + serial_number:_
```sql
create index test_table_i02 on test_table(id, serial_number);
```
_Теперь при запросах по id или по id + serial_number будет подключаться индекс:_
```
explain
select * from test_table where id = 101;

QUERY PLAN                                                                      |
--------------------------------------------------------------------------------+
Index Scan using test_table_i02 on test_table  (cost=0.42..8.44 rows=1 width=38)|
  Index Cond: (id = 101)                                                        |

explain
select * from test_table where id = 101 and serial_number = '34f3f060fe';

QUERY PLAN                                                                      |
--------------------------------------------------------------------------------+
Index Scan using test_table_i02 on test_table  (cost=0.42..8.45 rows=1 width=38)|
  Index Cond: ((id = 101) AND (serial_number = '34f3f060fe'::bpchar))           |
```
_Но если взять фильтр только по serial_number, то индекс не подключится:_
```sql
explain
select * from test_table where serial_number = '34f3f060fe';

QUERY PLAN                                                                  |
----------------------------------------------------------------------------+
Gather  (cost=1000.00..20026.43 rows=1 width=38)                            |
  Workers Planned: 2                                                        |
  ->  Parallel Seq Scan on test_table  (cost=0.00..19026.33 rows=1 width=38)|
        Filter: (serial_number = '34f3f060fe'::bpchar)                      |
```

_Только если использовать set enable_seqscan='off', то включается индекс:_
```
set enable_seqscan='off';
explain
select * from test_table where serial_number = '34f3f060fe';

QUERY PLAN                                                                          |
------------------------------------------------------------------------------------+
Index Scan using test_table_i02 on test_table  (cost=0.42..22896.43 rows=1 width=38)|
  Index Cond: (serial_number = '34f3f060fe'::bpchar)                                |
```

2 вариант:
В результате выполнения ДЗ вы научитесь пользоваться различными вариантами соединения таблиц.
В данном задании тренируются навыки:
- написания запросов с различными типами соединений
Необходимо:
1) Реализовать прямое соединение двух или более таблиц
2) Реализовать левостороннее (или правостороннее) соединение двух или более таблиц
3) Реализовать кросс соединение двух или более таблиц
4) Реализовать полное соединение двух или более таблиц
5) Реализовать запрос, в котором будут использованы разные типы соединений
6) Сделать комментарии на каждый запрос
7) К работе приложить структуру таблиц, для которых выполнялись соединения

_Таблицы:_
```sql
create table phones(id integer, city_id integer, phone_number char(12));

create table cities(id integer, city_name char(32));

insert into cities values (1, 'Moscow'), (2, 'Rostov'), (3, 'Spb');

insert into phones(id, city_id, phone_number)
values (1, 1, '+71112223344'), (2, 2, '+79998887766'), (3, 4, '+75556667788'), (4, 3, '+72223334455');
```

_1) Прямое соединение (inner join) таблиц cities и phones по city_id:_
```
select *
  from cities c
  join phones p on c.id = p.city_id;

id|city_name                       |id|city_id|phone_number|
--+--------------------------------+--+-------+------------+
 1|Moscow                          | 1|      1|+71112223344|
 2|Rostov                          | 2|      2|+79998887766|
 3|Spb                             | 4|      3|+72223334455|
```
_Выпал телефон с ID = 3, так как у него указан город с City_ID = 4, которого нет в таблице cities._

_2) Левостороннее соединение (left join) таблиц phones и cities по city_id:_
```sql
select *
  from phones p
  left join cities c on c.id = p.city_id;

id|city_id|phone_number|id|city_name                       |
--+-------+------------+--+--------------------------------+
 1|      1|+71112223344| 1|Moscow                          |
 2|      2|+79998887766| 2|Rostov                          |
 3|      4|+75556667788|  |                                |
 4|      3|+72223334455| 3|Spb                             |
```
_Теперь телефон попадает, так как поменялся порядок таблиц и левостороннее соединение позволило его отобразить, хоть у него и нет связки с cities_

_3) Кросс соединение (cross join) таблиц cities и phones:_
```sql
select *
  from cities c
  cross join phones p;

id|city_name                       |id|city_id|phone_number|
--+--------------------------------+--+-------+------------+
 1|Moscow                          | 1|      1|+71112223344|
 2|Rostov                          | 1|      1|+71112223344|
 3|Spb                             | 1|      1|+71112223344|
 1|Moscow                          | 2|      2|+79998887766|
 2|Rostov                          | 2|      2|+79998887766|
 3|Spb                             | 2|      2|+79998887766|
 1|Moscow                          | 3|      4|+75556667788|
 2|Rostov                          | 3|      4|+75556667788|
 3|Spb                             | 3|      4|+75556667788|
 1|Moscow                          | 4|      3|+72223334455|
 2|Rostov                          | 4|      3|+72223334455|
 3|Spb                             | 4|      3|+72223334455|
```
_Получили декартово произведение записей одной таблицы на другую._

_4) Полное соединение (full join) таблиц cities и phones:_
```sql
select *
  from cities c
  full join phones p on c.id = p.city_id;

id|city_name                       |id|city_id|phone_number|
--+--------------------------------+--+-------+------------+
 1|Moscow                          | 1|      1|+71112223344|
 2|Rostov                          | 2|      2|+79998887766|
  |                                | 3|      4|+75556667788|
 3|Spb                             | 4|      3|+72223334455|
```
_В отличие от 1 примера теперь выводятся все телефоны, хоть города в cities нет._

_5) К запросу из примера 1 добавим ещё раз таблицу phones, но через правостороннее соединение (right join), чтобы телефон без города в cities в итоге отобразился:_
```sql
select *
  from cities c
  join phones p on c.id = p.city_id
  right join phones pp on c.id = pp.city_id;

id|city_name                       |id|city_id|phone_number|id|city_id|phone_number|
--+--------------------------------+--+-------+------------+--+-------+------------+
 1|Moscow                          | 1|      1|+71112223344| 1|      1|+71112223344|
 2|Rostov                          | 2|      2|+79998887766| 2|      2|+79998887766|
 3|Spb                             | 4|      3|+72223334455| 4|      3|+72223334455|
  |                                |  |       |            | 3|      4|+75556667788|
```