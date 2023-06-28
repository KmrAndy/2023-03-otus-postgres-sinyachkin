# Домашнее задание
## Нагрузочное тестирование и тюнинг PostgreSQL

### Цель:
- сделать нагрузочное тестирование PostgreSQL
- настроить параметры PostgreSQL для достижения максимальной производительности

### Описание/Пошаговая инструкция выполнения домашнего задания:
1) развернуть виртуальную машину любым удобным способом
_Развернул в ЯО_
2) поставить на неё PostgreSQL 15 любым способом
```
sudo apt update && sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y -q && sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - && sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt -y install postgresql-15
```
3) настроить кластер PostgreSQL 15 на максимальную производительность не обращая внимание на возможные проблемы с надежностью в случае аварийной перезагрузки виртуальной машины}

_Дефолтные настройки_
```
             name             | setting
------------------------------+---------
 checkpoint_completion_target | 0.9
 default_statistics_target    | 100
 effective_cache_size         | 524288
 effective_io_concurrency     | 1
 maintenance_work_mem         | 65536
 max_connections              | 100
 max_wal_size                 | 1024
 min_wal_size                 | 80
 random_page_cost             | 4
 shared_buffers               | 16384
 wal_buffers                  | 512
 work_mem                     | 4096
(12 rows)
```
_Создадим БД для тестов_
```
postgres@postgres:/home/kmrandy$ pgbench -i postgres
dropping old tables...
NOTICE:  table "pgbench_accounts" does not exist, skipping
NOTICE:  table "pgbench_branches" does not exist, skipping
NOTICE:  table "pgbench_history" does not exist, skipping
NOTICE:  table "pgbench_tellers" does not exist, skipping
creating tables...
generating data (client-side)...
100000 of 100000 tuples (100%) done (elapsed 0.07 s, remaining 0.00 s)
vacuuming...
creating primary keys...
done in 2.12 s (drop tables 0.00 s, create tables 0.01 s, client-side generate 0.68 s, vacuum 0.04 s, primary keys 1.39 s).
```

_Выполним тест с дефолтными настройками для 8 клиентов_
```
postgres@postgres:/home/kmrandy$ postgres@postgres:/home/kmrandy$ pgbench -c 8 -P 6 -T 60 -U postgres postgres
pgbench (15.3 (Ubuntu 15.3-1.pgdg22.04+1))
starting vacuum...end.
progress: 6.0 s, 346.7 tps, lat 22.956 ms stddev 71.554, 0 failed
progress: 12.0 s, 664.5 tps, lat 12.049 ms stddev 7.324, 0 failed
progress: 18.0 s, 544.5 tps, lat 14.702 ms stddev 52.052, 0 failed
progress: 24.0 s, 694.3 tps, lat 11.519 ms stddev 9.327, 0 failed
progress: 30.0 s, 676.3 tps, lat 11.755 ms stddev 9.159, 0 failed
progress: 36.0 s, 346.2 tps, lat 23.225 ms stddev 21.957, 0 failed
progress: 42.0 s, 602.2 tps, lat 13.299 ms stddev 8.012, 0 failed
progress: 48.0 s, 653.3 tps, lat 12.244 ms stddev 7.840, 0 failed
progress: 54.0 s, 719.3 tps, lat 11.122 ms stddev 7.026, 0 failed
progress: 60.0 s, 740.2 tps, lat 10.751 ms stddev 6.816, 0 failed
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 8
number of threads: 1
maximum number of tries: 1
duration: 60 s
number of transactions actually processed: 35933
number of failed transactions: 0 (0.000%)
latency average = 13.357 ms
latency stddev = 25.198 ms
initial connection time = 17.164 ms
tps = 598.700161 (without initial connection time)
```

_Поменяем значения параметров конфигурации на предлагаемые в PGTune_
```sql
postgres=# alter system set max_connections = 100;
ALTER SYSTEM
postgres=# alter system set shared_buffers = '1GB';
ALTER SYSTEM
postgres=# alter system set effective_cache_size = '3GB';
ALTER SYSTEM
postgres=# alter system set maintenance_work_mem = '256MB';
ALTER SYSTEM
postgres=# alter system set checkpoint_completion_target = 0.9;
ALTER SYSTEM
postgres=# alter system set wal_buffers = '16MB';
ALTER SYSTEM
postgres=# alter system set random_page_cost = 1.1;
ALTER SYSTEM
postgres=# alter system set effective_io_concurrency = 200;
ALTER SYSTEM
postgres=# alter system set work_mem = '5242kB';
ALTER SYSTEM
postgres=# alter system set min_wal_size = '2GB';
ALTER SYSTEM
postgres=# alter system set max_wal_size = '8GB';
ALTER SYSTEM
```

4) нагрузить кластер через утилиту через утилиту pgbench (https://postgrespro.ru/docs/postgrespro/14/pgbench)
_Снова проведём тест_
```
postgres@postgres:/home/kmrandy$ pgbench -c 8 -P 6 -T 60 -U postgres postgres
pgbench (15.3 (Ubuntu 15.3-1.pgdg22.04+1))
starting vacuum...end.
progress: 6.0 s, 594.8 tps, lat 13.398 ms stddev 10.265, 0 failed
progress: 12.0 s, 666.0 tps, lat 12.000 ms stddev 9.480, 0 failed
progress: 18.0 s, 690.3 tps, lat 11.551 ms stddev 7.952, 0 failed
progress: 24.0 s, 742.3 tps, lat 10.802 ms stddev 6.079, 0 failed
progress: 30.0 s, 513.5 tps, lat 15.578 ms stddev 13.692, 0 failed
progress: 36.0 s, 714.5 tps, lat 11.154 ms stddev 9.419, 0 failed
progress: 42.0 s, 647.3 tps, lat 12.394 ms stddev 8.566, 0 failed
progress: 48.0 s, 709.0 tps, lat 11.266 ms stddev 7.329, 0 failed
progress: 54.0 s, 674.5 tps, lat 11.864 ms stddev 8.168, 0 failed
progress: 60.0 s, 491.3 tps, lat 16.211 ms stddev 15.241, 0 failed
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 8
number of threads: 1
maximum number of tries: 1
duration: 60 s
number of transactions actually processed: 38670
number of failed transactions: 0 (0.000%)
latency average = 12.408 ms
latency stddev = 9.793 ms
initial connection time = 16.654 ms
tps = 644.264693 (without initial connection time)
```
_Результат немного улучшился_

5) написать какого значения tps удалось достичь, показать какие параметры в какие значения устанавливали и почему
_Настраивал по учебнику, после каждой смены делал restart сервера:_
_max_connections - 100, не влияет на тест, одновременно было 8 клиентов и все в 1 поток_
_shared_buffers - 25% от общей RAM, ставил 50% в паре с effective_cache_size - разницы не увидел_
_effective_cache_size - 75% от общей RAM, ставил 50% в паре с shared_buffers - разницы не увидел_
_work_mem - ставил 5 МБ (по предложению PGTune) и 20 МБ от себя - разницы не увидел_
_wal_buffers - Ставил 16 МБ по учебнику и 100 МБ от себя - разницы не увидел_
_effective_io_concurrency - ставил 200 как предлагает PGTune для SSD дисков, ставил 1000 и 10 от себя - разницы не заметил_
_Но при указании в pgbench параметра -j8, который отвечает за количество параллельных тредов, результат немного улучшился_
```
postgres@postgres:/home/kmrandy$ pgbench -c 8 -P 6 -T 60 -j 8 -U postgres postgres
pgbench (15.3 (Ubuntu 15.3-1.pgdg22.04+1))
starting vacuum...end.
progress: 6.0 s, 619.0 tps, lat 12.872 ms stddev 10.910, 0 failed
progress: 12.0 s, 695.2 tps, lat 11.511 ms stddev 7.407, 0 failed
progress: 18.0 s, 662.5 tps, lat 12.004 ms stddev 12.115, 0 failed
progress: 24.0 s, 662.7 tps, lat 12.117 ms stddev 11.310, 0 failed
progress: 30.0 s, 768.5 tps, lat 10.438 ms stddev 6.527, 0 failed
progress: 36.0 s, 702.7 tps, lat 11.381 ms stddev 8.836, 0 failed
progress: 42.0 s, 725.8 tps, lat 11.019 ms stddev 7.876, 0 failed
progress: 48.0 s, 656.0 tps, lat 12.137 ms stddev 11.561, 0 failed
progress: 54.0 s, 506.3 tps, lat 15.861 ms stddev 16.880, 0 failed
progress: 60.0 s, 722.3 tps, lat 11.092 ms stddev 8.205, 0 failed
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 8
number of threads: 8
maximum number of tries: 1
duration: 60 s
number of transactions actually processed: 40333
number of failed transactions: 0 (0.000%)
latency average = 11.900 ms
latency stddev = 10.340 ms
initial connection time = 14.472 ms
tps = 672.091456 (without initial connection time)
```
_Причём при дефолтных настройках и при настройках из PGTune результат был хуже, чем при effective_io_concurrency = 10 и work_mem = 20 MB и shared_buffers с effective_cache_size, разделенными поровну_

_Но самый главный прирост даёт установка значения параметра synchronous_commit = off_
```
postgres@postgres:/home/kmrandy$ pgbench -c 8 -P 6 -T 60 -j 8 -U postgres postgres
pgbench (15.3 (Ubuntu 15.3-1.pgdg22.04+1))
starting vacuum...end.
progress: 6.0 s, 3533.1 tps, lat 2.258 ms stddev 0.721, 0 failed
progress: 12.0 s, 3594.5 tps, lat 2.225 ms stddev 0.653, 0 failed
progress: 18.0 s, 3584.0 tps, lat 2.232 ms stddev 0.657, 0 failed
progress: 24.0 s, 3515.3 tps, lat 2.275 ms stddev 0.692, 0 failed
progress: 30.0 s, 3529.7 tps, lat 2.266 ms stddev 0.636, 0 failed
progress: 36.0 s, 3500.3 tps, lat 2.285 ms stddev 2.603, 0 failed
progress: 42.0 s, 3455.2 tps, lat 2.315 ms stddev 0.649, 0 failed
progress: 48.0 s, 3506.8 tps, lat 2.281 ms stddev 0.678, 0 failed
progress: 54.0 s, 3433.7 tps, lat 2.329 ms stddev 0.855, 0 failed
progress: 60.0 s, 3377.2 tps, lat 2.369 ms stddev 0.755, 0 failed
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 8
number of threads: 8
maximum number of tries: 1
duration: 60 s
number of transactions actually processed: 210186
number of failed transactions: 0 (0.000%)
latency average = 2.283 ms
latency stddev = 1.060 ms
initial connection time = 13.605 ms
tps = 3503.217767 (without initial connection time)
```

_Прирост транзакций практически в 6 раз_
6) Задание со *: аналогично протестировать через утилиту https://github.com/Percona-Lab/sysbench-tpcc (требует установки https://github.com/akopytov/sysbench)
_Задание со * не делал_