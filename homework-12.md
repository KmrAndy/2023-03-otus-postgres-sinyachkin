# Домашнее задание
## Секционирование таблицы

### Цель:
- научиться секционировать таблицы.

### Описание/Пошаговая инструкция выполнения домашнего задания:
1) Секционировать большую таблицу из демо базы flights

_Установил версию big БД flights_
_В БД нет ни одной партиционированной таблицы_
```sql
select count(1) from pg_catalog.pg_partitioned_table;

count|
-----+
    0|
```
_Будем партиционировать таблицу bookings по полю book_date. Сделаем месячные партиции._
_Сейчас план запроса к таблице выглядит следующим образом:_
```sql
explain (analyze)
select * from bookings b
where book_date = to_timestamp('2016-08-13', 'yyyy-mm-dd') ;
```
```sql
QUERY PLAN                                                                                                                |
--------------------------------------------------------------------------------------------------------------------------+
Gather  (cost=1000.00..27641.94 rows=5 width=21) (actual time=326.180..817.644 rows=4 loops=1)                            |
  Workers Planned: 2                                                                                                      |
  Workers Launched: 2                                                                                                     |
  ->  Parallel Seq Scan on bookings b  (cost=0.00..26641.44 rows=2 width=21) (actual time=620.801..799.677 rows=1 loops=3)|
        Filter: (book_date = to_timestamp('2016-08-13'::text, 'yyyy-mm-dd'::text))                                        |
        Rows Removed by Filter: 703702                                                                                    |
Planning Time: 0.058 ms                                                                                                   |
Execution Time: 817.668 ms                                                                                                |
```

_Создадим новую таблицу bookings_new:_
```sql
CREATE TABLE bookings_new (
       book_ref     character(6),
       book_date    timestamptz,
       total_amount numeric(10,2),
       CONSTRAINT bookings_new_pkey PRIMARY KEY (book_ref, book_date)
   ) PARTITION BY RANGE(book_date);
```

_В таблице bookings данные лежат с 2016-07-20 по 2017-08-15_
```sql
select min(book_date), max(book_date) from bookings b

min                          |max                          |
-----------------------------+-----------------------------+
2016-07-20 21:16:00.000 +0300|2017-08-15 18:00:00.000 +0300|
```
_Создадим месячные партиции для bookings_new на 2016 и 2017 годы:_
```sql
CREATE TABLE bookings_201601 PARTITION OF bookings_new FOR VALUES FROM ('2016-01-01'::timestamptz) TO ('2016-02-01'::timestamptz);
CREATE TABLE bookings_201602 PARTITION OF bookings_new FOR VALUES FROM ('2016-02-01'::timestamptz) TO ('2016-03-01'::timestamptz);
CREATE TABLE bookings_201603 PARTITION OF bookings_new FOR VALUES FROM ('2016-03-01'::timestamptz) TO ('2016-04-01'::timestamptz);
CREATE TABLE bookings_201604 PARTITION OF bookings_new FOR VALUES FROM ('2016-04-01'::timestamptz) TO ('2016-05-01'::timestamptz);
CREATE TABLE bookings_201605 PARTITION OF bookings_new FOR VALUES FROM ('2016-05-01'::timestamptz) TO ('2016-06-01'::timestamptz);
CREATE TABLE bookings_201606 PARTITION OF bookings_new FOR VALUES FROM ('2016-06-01'::timestamptz) TO ('2016-07-01'::timestamptz);
CREATE TABLE bookings_201607 PARTITION OF bookings_new FOR VALUES FROM ('2016-07-01'::timestamptz) TO ('2016-08-01'::timestamptz);
CREATE TABLE bookings_201608 PARTITION OF bookings_new FOR VALUES FROM ('2016-08-01'::timestamptz) TO ('2016-09-01'::timestamptz);
CREATE TABLE bookings_201609 PARTITION OF bookings_new FOR VALUES FROM ('2016-09-01'::timestamptz) TO ('2016-10-01'::timestamptz);
CREATE TABLE bookings_201610 PARTITION OF bookings_new FOR VALUES FROM ('2016-10-01'::timestamptz) TO ('2016-11-01'::timestamptz);
CREATE TABLE bookings_201611 PARTITION OF bookings_new FOR VALUES FROM ('2016-11-01'::timestamptz) TO ('2016-12-01'::timestamptz);
CREATE TABLE bookings_201612 PARTITION OF bookings_new FOR VALUES FROM ('2016-12-01'::timestamptz) TO ('2017-01-01'::timestamptz);
CREATE TABLE bookings_201701 PARTITION OF bookings_new FOR VALUES FROM ('2017-01-01'::timestamptz) TO ('2017-02-01'::timestamptz);
CREATE TABLE bookings_201702 PARTITION OF bookings_new FOR VALUES FROM ('2017-02-01'::timestamptz) TO ('2017-03-01'::timestamptz);
CREATE TABLE bookings_201703 PARTITION OF bookings_new FOR VALUES FROM ('2017-03-01'::timestamptz) TO ('2017-04-01'::timestamptz);
CREATE TABLE bookings_201704 PARTITION OF bookings_new FOR VALUES FROM ('2017-04-01'::timestamptz) TO ('2017-05-01'::timestamptz);
CREATE TABLE bookings_201705 PARTITION OF bookings_new FOR VALUES FROM ('2017-05-01'::timestamptz) TO ('2017-06-01'::timestamptz);
CREATE TABLE bookings_201706 PARTITION OF bookings_new FOR VALUES FROM ('2017-06-01'::timestamptz) TO ('2017-07-01'::timestamptz);
CREATE TABLE bookings_201707 PARTITION OF bookings_new FOR VALUES FROM ('2017-07-01'::timestamptz) TO ('2017-08-01'::timestamptz);
CREATE TABLE bookings_201708 PARTITION OF bookings_new FOR VALUES FROM ('2017-08-01'::timestamptz) TO ('2017-09-01'::timestamptz);
CREATE TABLE bookings_201709 PARTITION OF bookings_new FOR VALUES FROM ('2017-09-01'::timestamptz) TO ('2017-10-01'::timestamptz);
CREATE TABLE bookings_201710 PARTITION OF bookings_new FOR VALUES FROM ('2017-10-01'::timestamptz) TO ('2017-11-01'::timestamptz);
CREATE TABLE bookings_201711 PARTITION OF bookings_new FOR VALUES FROM ('2017-11-01'::timestamptz) TO ('2017-12-01'::timestamptz);
CREATE TABLE bookings_201712 PARTITION OF bookings_new FOR VALUES FROM ('2017-12-01'::timestamptz) TO ('2018-01-01'::timestamptz);
```
_Копируем данные из bookings в bookings_new:_
```sql
INSERT INTO bookings_new SELECT * FROM bookings;
```

_На зависимой таблице tickets есть внешний ключ на таблицу bookings._
_Чтобы повторить такой ключ на новой таблице bookings_new - нужно добавить колонку book_date в таблицу tickets, так как первичный ключ у bookings_new теперь состоит из book_ref и book_date:_
```sql
alter table tickets add column book_date timestamptz;
```
_Проапдейтим колонку book_date значениями из bookings:_
```sql
update tickets t set book_date = b.book_date from bookings b where t.book_ref = b.book_ref;
```
_Установим not null для поля book_date таблицы tickets:_
```sql
alter table tickets alter column book_date set not null;
```

_Удалим внешний ключ на таблицу bookings и создадим новый на таблицу bookings_new:_
```sql
alter table tickets drop constraint tickets_book_ref_fkey;
alter table tickets add constraint tickets_book_ref_fkey foreign key (book_ref, book_date) references bookings_new (book_ref, book_date);
```
_Делаем ренейм таблиц bookings и bookings_new:_
```sql
alter table bookings rename to bookings_old;
alter table bookings_new rename to bookings;
```

_Делаем запрос из самого начала к bookings и проверяем, что в плане теперь используются партиции:_
```sql
explain (analyze)
select * from bookings b
where book_date = to_timestamp('2016-08-13', 'yyyy-mm-dd');

QUERY PLAN                                                                                                                            |
--------------------------------------------------------------------------------------------------------------------------------------+
Gather  (cost=1000.00..33283.17 rows=115 width=34) (actual time=53.713..71.904 rows=4 loops=1)                                        |
  Workers Planned: 2                                                                                                                  |
  Workers Launched: 2                                                                                                                 |
  ->  Parallel Append  (cost=0.00..32271.67 rows=45 width=34) (actual time=39.653..60.934 rows=1 loops=3)                             |
        Subplans Removed: 23                                                                                                          |
        ->  Parallel Seq Scan on bookings_201608 b_1  (cost=0.00..2558.26 rows=3 width=21) (actual time=39.652..60.931 rows=1 loops=3)|
              Filter: (book_date = to_timestamp('2016-08-13'::text, 'yyyy-mm-dd'::text))                                              |
              Rows Removed by Filter: 56108                                                                                           |
Planning Time: 0.415 ms                                                                                                               |
Execution Time: 71.928 ms                                                                                                             |
```

