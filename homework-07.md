# Домашнее задание
## Работа с журналами

### Цель:
- уметь работать с журналами и контрольными точками
- уметь настраивать параметры журналов

### Описание/Пошаговая инструкция выполнения домашнего задания:
1) Настройте выполнение контрольной точки раз в 30 секунд.
_Установил в postgresql.conf параметр checkpoint_timeout = 30s. Перезагрузил кластер_
2) 10 минут c помощью утилиты pgbench подавайте нагрузку.
```
postgres@postgres:/etc/postgresql/15/main$ pgbench -P 10 -T 600 -U postgres postgres
pgbench (15.3 (Ubuntu 15.3-1.pgdg22.04+1))
starting vacuum...end.
progress: 10.0 s, 609.5 tps, lat 1.639 ms stddev 1.520, 0 failed
progress: 20.0 s, 717.3 tps, lat 1.394 ms stddev 1.346, 0 failed
progress: 30.0 s, 329.1 tps, lat 3.037 ms stddev 3.625, 0 failed
progress: 40.0 s, 509.3 tps, lat 1.963 ms stddev 16.141, 0 failed
progress: 50.0 s, 615.2 tps, lat 1.625 ms stddev 1.875, 0 failed
progress: 60.0 s, 730.7 tps, lat 1.368 ms stddev 1.305, 0 failed
progress: 70.0 s, 586.7 tps, lat 1.705 ms stddev 1.969, 0 failed
progress: 80.0 s, 498.5 tps, lat 2.005 ms stddev 1.711, 0 failed
progress: 90.0 s, 605.8 tps, lat 1.649 ms stddev 1.603, 0 failed
progress: 100.0 s, 502.3 tps, lat 1.992 ms stddev 1.797, 0 failed
progress: 110.0 s, 559.5 tps, lat 1.787 ms stddev 14.096, 0 failed
progress: 120.0 s, 644.3 tps, lat 1.552 ms stddev 1.852, 0 failed
progress: 130.0 s, 509.7 tps, lat 1.961 ms stddev 2.310, 0 failed
progress: 140.0 s, 702.8 tps, lat 1.422 ms stddev 1.330, 0 failed
progress: 150.0 s, 592.3 tps, lat 1.688 ms stddev 2.308, 0 failed
progress: 160.0 s, 523.0 tps, lat 1.912 ms stddev 2.289, 0 failed
progress: 170.0 s, 657.4 tps, lat 1.521 ms stddev 1.272, 0 failed
progress: 180.0 s, 630.7 tps, lat 1.585 ms stddev 1.493, 0 failed
progress: 190.0 s, 317.9 tps, lat 3.145 ms stddev 2.983, 0 failed
progress: 200.0 s, 343.6 tps, lat 2.910 ms stddev 2.901, 0 failed
progress: 210.0 s, 654.0 tps, lat 1.528 ms stddev 1.522, 0 failed
progress: 220.0 s, 595.0 tps, lat 1.681 ms stddev 2.285, 0 failed
progress: 230.0 s, 389.4 tps, lat 2.566 ms stddev 2.235, 0 failed
progress: 240.0 s, 677.1 tps, lat 1.477 ms stddev 1.970, 0 failed
progress: 250.0 s, 600.9 tps, lat 1.664 ms stddev 3.419, 0 failed
progress: 260.0 s, 742.8 tps, lat 1.346 ms stddev 1.308, 0 failed
progress: 270.0 s, 660.2 tps, lat 1.514 ms stddev 1.496, 0 failed
progress: 280.0 s, 490.4 tps, lat 2.039 ms stddev 2.450, 0 failed
progress: 290.0 s, 450.4 tps, lat 2.220 ms stddev 2.102, 0 failed
progress: 300.0 s, 712.0 tps, lat 1.404 ms stddev 1.342, 0 failed
progress: 310.0 s, 399.6 tps, lat 2.502 ms stddev 2.456, 0 failed
progress: 320.0 s, 731.6 tps, lat 1.366 ms stddev 1.145, 0 failed
progress: 330.0 s, 706.5 tps, lat 1.415 ms stddev 1.217, 0 failed
progress: 340.0 s, 517.9 tps, lat 1.930 ms stddev 1.861, 0 failed
progress: 350.0 s, 663.9 tps, lat 1.506 ms stddev 1.384, 0 failed
progress: 360.0 s, 730.4 tps, lat 1.369 ms stddev 1.296, 0 failed
progress: 370.0 s, 621.3 tps, lat 1.609 ms stddev 1.849, 0 failed
progress: 380.0 s, 708.2 tps, lat 1.412 ms stddev 2.569, 0 failed
progress: 390.0 s, 677.6 tps, lat 1.475 ms stddev 2.081, 0 failed
progress: 400.0 s, 619.8 tps, lat 1.614 ms stddev 2.043, 0 failed
progress: 410.0 s, 723.9 tps, lat 1.381 ms stddev 1.149, 0 failed
progress: 420.0 s, 670.2 tps, lat 1.491 ms stddev 1.618, 0 failed
progress: 430.0 s, 565.8 tps, lat 1.767 ms stddev 3.703, 0 failed
progress: 440.0 s, 702.0 tps, lat 1.423 ms stddev 2.485, 0 failed
progress: 450.0 s, 691.4 tps, lat 1.446 ms stddev 1.464, 0 failed
progress: 460.0 s, 502.0 tps, lat 1.991 ms stddev 2.117, 0 failed
progress: 470.0 s, 572.1 tps, lat 1.747 ms stddev 1.727, 0 failed
progress: 480.0 s, 719.6 tps, lat 1.389 ms stddev 1.306, 0 failed
progress: 490.0 s, 563.0 tps, lat 1.777 ms stddev 1.794, 0 failed
progress: 500.0 s, 611.9 tps, lat 1.633 ms stddev 1.710, 0 failed
progress: 510.0 s, 629.5 tps, lat 1.589 ms stddev 1.895, 0 failed
progress: 520.0 s, 610.0 tps, lat 1.638 ms stddev 1.661, 0 failed
progress: 530.0 s, 545.4 tps, lat 1.834 ms stddev 1.797, 0 failed
progress: 540.0 s, 610.4 tps, lat 1.638 ms stddev 1.682, 0 failed
progress: 550.0 s, 342.2 tps, lat 2.922 ms stddev 3.056, 0 failed
progress: 560.0 s, 457.3 tps, lat 2.186 ms stddev 2.888, 0 failed
progress: 570.0 s, 363.1 tps, lat 2.754 ms stddev 6.171, 0 failed
progress: 580.0 s, 638.1 tps, lat 1.567 ms stddev 1.635, 0 failed
progress: 590.0 s, 646.5 tps, lat 1.546 ms stddev 1.402, 0 failed
progress: 600.0 s, 725.9 tps, lat 1.377 ms stddev 1.429, 0 failed
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 1
number of threads: 1
maximum number of tries: 1
duration: 600 s
number of transactions actually processed: 354250
number of failed transactions: 0 (0.000%)
latency average = 1.693 ms
latency stddev = 3.320 ms
initial connection time = 2.331 ms
tps = 590.417763 (without initial connection time)
```
3) Измерьте, какой объем журнальных файлов был сгенерирован за это время. Оцените, какой объем приходится в среднем на одну контрольную точку.
_Каждый файл по 16 Мб._
```
postgres@postgres:~/15/main/pg_wal$ ls -lh *
-rw------- 1 postgres postgres  16M May 25 20:39 00000001000000000000001B
-rw------- 1 postgres postgres  16M May 25 20:36 00000001000000000000001C
-rw------- 1 postgres postgres  16M May 25 20:37 00000001000000000000001D
-rw------- 1 postgres postgres  16M May 25 20:37 00000001000000000000001E
```
_За 10 минут (600 секунд) было создано 20 контрольных точек (через каждые 30 секунд)_
_16 * 4 / 20 = 3,2 Мб на 1 контрольную точку_
4) Проверьте данные статистики: все ли контрольные точки выполнялись точно по расписанию. Почему так произошло?
```
2023-05-25 20:28:30.152 UTC [55290] LOG:  checkpoint starting: time
2023-05-25 20:28:57.194 UTC [55290] LOG:  checkpoint complete: wrote 2045 buffers (12.5%); 0 WAL file(s) added, 0 removed, 1 recycled; write=26.882 s, sync=0.079 s, total=27.042 s; sync files=10, longest=0.072 s, average=0.008 s; distance=21791 kB, estimate=21791 kB
2023-05-25 20:29:00.194 UTC [55290] LOG:  checkpoint starting: time
2023-05-25 20:29:27.117 UTC [55290] LOG:  checkpoint complete: wrote 1870 buffers (11.4%); 0 WAL file(s) added, 0 removed, 1 recycled; write=26.870 s, sync=0.023 s, total=26.924 s; sync files=15, longest=0.009 s, average=0.002 s; distance=20568 kB, estimate=21669 kB
2023-05-25 20:29:30.120 UTC [55290] LOG:  checkpoint starting: time
2023-05-25 20:29:57.129 UTC [55290] LOG:  checkpoint complete: wrote 1944 buffers (11.9%); 0 WAL file(s) added, 0 removed, 1 recycled; write=26.866 s, sync=0.086 s, total=27.009 s; sync files=8, longest=0.062 s, average=0.011 s; distance=20820 kB, estimate=21584 kB
2023-05-25 20:30:00.132 UTC [55290] LOG:  checkpoint starting: time
2023-05-25 20:30:27.115 UTC [55290] LOG:  checkpoint complete: wrote 2137 buffers (13.0%); 0 WAL file(s) added, 0 removed, 2 recycled; write=26.861 s, sync=0.048 s, total=26.983 s; sync files=15, longest=0.021 s, average=0.004 s; distance=22149 kB, estimate=22149 kB
2023-05-25 20:30:30.118 UTC [55290] LOG:  checkpoint starting: time
2023-05-25 20:30:57.055 UTC [55290] LOG:  checkpoint complete: wrote 1977 buffers (12.1%); 0 WAL file(s) added, 0 removed, 1 recycled; write=26.860 s, sync=0.034 s, total=26.938 s; sync files=7, longest=0.032 s, average=0.005 s; distance=22420 kB, estimate=22420 kB
2023-05-25 20:31:00.058 UTC [55290] LOG:  checkpoint starting: time
2023-05-25 20:31:27.134 UTC [55290] LOG:  checkpoint complete: wrote 2053 buffers (12.5%); 0 WAL file(s) added, 0 removed, 2 recycled; write=26.987 s, sync=0.010 s, total=27.076 s; sync files=12, longest=0.006 s, average=0.001 s; distance=21120 kB, estimate=22290 kB
2023-05-25 20:31:30.137 UTC [55290] LOG:  checkpoint starting: time
2023-05-25 20:31:57.048 UTC [55290] LOG:  checkpoint complete: wrote 1887 buffers (11.5%); 0 WAL file(s) added, 0 removed, 1 recycled; write=26.858 s, sync=0.009 s, total=26.912 s; sync files=6, longest=0.009 s, average=0.002 s; distance=18583 kB, estimate=21920 kB
2023-05-25 20:32:00.051 UTC [55290] LOG:  checkpoint starting: time
2023-05-25 20:32:27.102 UTC [55290] LOG:  checkpoint complete: wrote 2027 buffers (12.4%); 0 WAL file(s) added, 0 removed, 1 recycled; write=26.969 s, sync=0.030 s, total=27.051 s; sync files=10, longest=0.012 s, average=0.003 s; distance=19983 kB, estimate=21726 kB
2023-05-25 20:32:30.105 UTC [55290] LOG:  checkpoint starting: time
2023-05-25 20:32:57.078 UTC [55290] LOG:  checkpoint complete: wrote 1935 buffers (11.8%); 0 WAL file(s) added, 0 removed, 1 recycled; write=26.884 s, sync=0.047 s, total=26.974 s; sync files=6, longest=0.047 s, average=0.008 s; distance=21341 kB, estimate=21687 kB
2023-05-25 20:33:00.080 UTC [55290] LOG:  checkpoint starting: time
2023-05-25 20:33:27.057 UTC [55290] LOG:  checkpoint complete: wrote 2012 buffers (12.3%); 0 WAL file(s) added, 0 removed, 1 recycled; write=26.893 s, sync=0.019 s, total=26.978 s; sync files=11, longest=0.009 s, average=0.002 s; distance=19950 kB, estimate=21514 kB
2023-05-25 20:33:30.060 UTC [55290] LOG:  checkpoint starting: time
2023-05-25 20:33:57.126 UTC [55290] LOG:  checkpoint complete: wrote 1895 buffers (11.6%); 0 WAL file(s) added, 0 removed, 2 recycled; write=26.957 s, sync=0.045 s, total=27.067 s; sync files=6, longest=0.045 s, average=0.008 s; distance=20633 kB, estimate=21426 kB
2023-05-25 20:34:00.129 UTC [55290] LOG:  checkpoint starting: time
2023-05-25 20:34:27.073 UTC [55290] LOG:  checkpoint complete: wrote 2007 buffers (12.2%); 0 WAL file(s) added, 0 removed, 1 recycled; write=26.858 s, sync=0.036 s, total=26.945 s; sync files=11, longest=0.026 s, average=0.004 s; distance=20994 kB, estimate=21382 kB
2023-05-25 20:34:30.076 UTC [55290] LOG:  checkpoint starting: time
2023-05-25 20:34:57.136 UTC [55290] LOG:  checkpoint complete: wrote 1901 buffers (11.6%); 0 WAL file(s) added, 0 removed, 1 recycled; write=26.970 s, sync=0.045 s, total=27.060 s; sync files=6, longest=0.045 s, average=0.008 s; distance=21343 kB, estimate=21379 kB
2023-05-25 20:35:00.139 UTC [55290] LOG:  checkpoint starting: time
2023-05-25 20:35:27.104 UTC [55290] LOG:  checkpoint complete: wrote 2029 buffers (12.4%); 0 WAL file(s) added, 0 removed, 2 recycled; write=26.858 s, sync=0.057 s, total=26.966 s; sync files=12, longest=0.043 s, average=0.005 s; distance=21420 kB, estimate=21420 kB
2023-05-25 20:35:30.107 UTC [55290] LOG:  checkpoint starting: time
2023-05-25 20:35:57.125 UTC [55290] LOG:  checkpoint complete: wrote 1863 buffers (11.4%); 0 WAL file(s) added, 0 removed, 1 recycled; write=26.896 s, sync=0.040 s, total=27.018 s; sync files=6, longest=0.040 s, average=0.007 s; distance=21167 kB, estimate=21395 kB
2023-05-25 20:36:00.128 UTC [55290] LOG:  checkpoint starting: time
2023-05-25 20:36:27.097 UTC [55290] LOG:  checkpoint complete: wrote 1967 buffers (12.0%); 0 WAL file(s) added, 0 removed, 1 recycled; write=26.883 s, sync=0.043 s, total=26.969 s; sync files=8, longest=0.041 s, average=0.006 s; distance=20528 kB, estimate=21308 kB
2023-05-25 20:36:30.098 UTC [55290] LOG:  checkpoint starting: time
2023-05-25 20:36:57.076 UTC [55290] LOG:  checkpoint complete: wrote 1851 buffers (11.3%); 0 WAL file(s) added, 0 removed, 1 recycled; write=26.859 s, sync=0.045 s, total=26.979 s; sync files=6, longest=0.045 s, average=0.008 s; distance=20547 kB, estimate=21232 kB
2023-05-25 20:37:00.079 UTC [55290] LOG:  checkpoint starting: time
2023-05-25 20:37:27.054 UTC [55290] LOG:  checkpoint complete: wrote 2212 buffers (13.5%); 0 WAL file(s) added, 0 removed, 2 recycled; write=26.902 s, sync=0.022 s, total=26.975 s; sync files=12, longest=0.010 s, average=0.002 s; distance=20451 kB, estimate=21154 kB
2023-05-25 20:37:30.057 UTC [55290] LOG:  checkpoint starting: time
2023-05-25 20:37:57.081 UTC [55290] LOG:  checkpoint complete: wrote 1747 buffers (10.7%); 0 WAL file(s) added, 0 removed, 1 recycled; write=26.974 s, sync=0.010 s, total=27.025 s; sync files=6, longest=0.008 s, average=0.002 s; distance=17983 kB, estimate=20837 kB
2023-05-25 20:38:00.084 UTC [55290] LOG:  checkpoint starting: time
2023-05-25 20:38:27.074 UTC [55290] LOG:  checkpoint complete: wrote 1835 buffers (11.2%); 0 WAL file(s) added, 0 removed, 1 recycled; write=26.965 s, sync=0.002 s, total=26.991 s; sync files=10, longest=0.002 s, average=0.001 s; distance=21387 kB, estimate=21387 kB
2023-05-25 20:39:00.078 UTC [55290] LOG:  checkpoint starting: time
2023-05-25 20:39:27.064 UTC [55290] LOG:  checkpoint complete: wrote 2023 buffers (12.3%); 0 WAL file(s) added, 0 removed, 0 recycled; write=26.966 s, sync=0.004 s, total=26.987 s; sync files=11, longest=0.003 s, average=0.001 s; distance=1090 kB, estimate=19358 kB
```
_Все точки выполнялись по расписанию._
5) Сравните tps в синхронном/асинхронном режиме утилитой pgbench. Объясните полученный результат.
_Выставим параметру synchronous_commit значение off_
```sql
postgres=# ALTER SYSTEM SET synchronous_commit = off;
```
_Запустим тест_
```
postgres@postgres:/home/kmrandy$ pgbench -P 10 -T 600 -U postgres postgres
pgbench (15.3 (Ubuntu 15.3-1.pgdg22.04+1))
starting vacuum...end.
progress: 10.0 s, 2521.7 tps, lat 0.396 ms stddev 0.060, 0 failed
progress: 20.0 s, 2463.6 tps, lat 0.406 ms stddev 0.035, 0 failed
progress: 30.0 s, 2509.4 tps, lat 0.398 ms stddev 0.078, 0 failed
progress: 40.0 s, 2323.6 tps, lat 0.430 ms stddev 4.625, 0 failed
progress: 50.0 s, 2280.5 tps, lat 0.438 ms stddev 4.868, 0 failed
progress: 60.0 s, 2471.3 tps, lat 0.404 ms stddev 0.086, 0 failed
progress: 70.0 s, 2437.3 tps, lat 0.410 ms stddev 0.098, 0 failed
progress: 80.0 s, 2458.9 tps, lat 0.406 ms stddev 0.048, 0 failed
progress: 90.0 s, 2469.8 tps, lat 0.405 ms stddev 0.070, 0 failed
progress: 100.0 s, 2519.5 tps, lat 0.397 ms stddev 0.039, 0 failed
progress: 110.0 s, 2462.1 tps, lat 0.406 ms stddev 0.036, 0 failed
progress: 120.0 s, 2466.1 tps, lat 0.405 ms stddev 0.123, 0 failed
progress: 130.0 s, 2456.8 tps, lat 0.407 ms stddev 0.050, 0 failed
progress: 140.0 s, 2450.6 tps, lat 0.408 ms stddev 0.059, 0 failed
progress: 150.0 s, 2449.8 tps, lat 0.408 ms stddev 0.108, 0 failed
progress: 160.0 s, 2462.5 tps, lat 0.406 ms stddev 0.098, 0 failed
progress: 170.0 s, 2478.1 tps, lat 0.403 ms stddev 0.039, 0 failed
progress: 180.0 s, 2456.1 tps, lat 0.407 ms stddev 0.074, 0 failed
progress: 190.0 s, 2486.5 tps, lat 0.402 ms stddev 0.100, 0 failed
progress: 200.0 s, 2499.3 tps, lat 0.400 ms stddev 0.055, 0 failed
progress: 210.0 s, 2486.8 tps, lat 0.402 ms stddev 0.059, 0 failed
progress: 220.0 s, 2495.9 tps, lat 0.400 ms stddev 0.076, 0 failed
progress: 230.0 s, 2465.1 tps, lat 0.405 ms stddev 0.081, 0 failed
progress: 240.0 s, 2471.7 tps, lat 0.404 ms stddev 0.068, 0 failed
progress: 250.0 s, 2468.7 tps, lat 0.405 ms stddev 0.098, 0 failed
progress: 260.0 s, 2449.7 tps, lat 0.408 ms stddev 0.049, 0 failed
progress: 270.0 s, 2447.3 tps, lat 0.408 ms stddev 0.030, 0 failed
progress: 280.0 s, 2446.8 tps, lat 0.408 ms stddev 0.040, 0 failed
progress: 290.0 s, 2454.6 tps, lat 0.407 ms stddev 0.073, 0 failed
progress: 300.0 s, 2466.5 tps, lat 0.405 ms stddev 0.104, 0 failed
progress: 310.0 s, 2470.4 tps, lat 0.404 ms stddev 0.069, 0 failed
progress: 320.0 s, 2499.0 tps, lat 0.400 ms stddev 0.032, 0 failed
progress: 330.0 s, 2477.7 tps, lat 0.403 ms stddev 0.083, 0 failed
progress: 340.0 s, 2503.5 tps, lat 0.399 ms stddev 0.045, 0 failed
progress: 350.0 s, 2468.9 tps, lat 0.405 ms stddev 0.063, 0 failed
progress: 360.0 s, 2462.4 tps, lat 0.406 ms stddev 0.077, 0 failed
progress: 370.0 s, 2458.1 tps, lat 0.406 ms stddev 0.057, 0 failed
progress: 380.0 s, 2469.2 tps, lat 0.405 ms stddev 0.083, 0 failed
progress: 390.0 s, 2486.2 tps, lat 0.402 ms stddev 0.047, 0 failed
progress: 400.0 s, 2530.3 tps, lat 0.395 ms stddev 0.028, 0 failed
progress: 410.0 s, 2481.6 tps, lat 0.403 ms stddev 0.066, 0 failed
progress: 420.0 s, 2488.8 tps, lat 0.401 ms stddev 0.077, 0 failed
progress: 430.0 s, 2510.0 tps, lat 0.398 ms stddev 0.094, 0 failed
progress: 440.0 s, 2479.8 tps, lat 0.403 ms stddev 0.021, 0 failed
progress: 450.0 s, 2498.3 tps, lat 0.400 ms stddev 0.047, 0 failed
progress: 460.0 s, 2487.7 tps, lat 0.402 ms stddev 0.080, 0 failed
progress: 470.0 s, 2482.3 tps, lat 0.402 ms stddev 0.050, 0 failed
progress: 480.0 s, 2458.1 tps, lat 0.406 ms stddev 0.120, 0 failed
progress: 490.0 s, 2476.8 tps, lat 0.403 ms stddev 0.094, 0 failed
progress: 500.0 s, 2519.4 tps, lat 0.397 ms stddev 0.023, 0 failed
progress: 510.0 s, 2455.4 tps, lat 0.407 ms stddev 0.064, 0 failed
progress: 520.0 s, 2458.6 tps, lat 0.406 ms stddev 0.063, 0 failed
progress: 530.0 s, 2472.8 tps, lat 0.404 ms stddev 0.079, 0 failed
progress: 540.0 s, 2476.3 tps, lat 0.403 ms stddev 0.115, 0 failed
progress: 550.0 s, 2456.8 tps, lat 0.407 ms stddev 0.156, 0 failed
progress: 560.0 s, 2468.7 tps, lat 0.405 ms stddev 0.064, 0 failed
progress: 570.0 s, 2434.8 tps, lat 0.410 ms stddev 0.054, 0 failed
progress: 580.0 s, 2435.6 tps, lat 0.410 ms stddev 0.067, 0 failed
progress: 590.0 s, 2422.3 tps, lat 0.412 ms stddev 0.046, 0 failed
progress: 600.0 s, 2418.6 tps, lat 0.413 ms stddev 0.080, 0 failed
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 1
number of threads: 1
maximum number of tries: 1
duration: 600 s
number of transactions actually processed: 1479851
number of failed transactions: 0 (0.000%)
latency average = 0.405 ms
latency stddev = 0.840 ms
initial connection time = 2.818 ms
tps = 2466.428178 (without initial connection time)
```
_Средний TPS вырос почти в 5 раз. Был 590 стал 2466._
_Опция synchronous_commit со значением off позволяет подтверждать транзакции до того, как они попали в лог._
_Из-за этого получаем прирост скорости, но есть вероятность при падении сервера потерять часть этих транзакций, которые ещё не успели попасть в лог._
6) Создайте новый кластер с включенной контрольной суммой страниц. Создайте таблицу. Вставьте несколько значений.
Выключите кластер. Измените пару байт в таблице. Включите кластер и сделайте выборку из таблицы.
Что и почему произошло? как проигнорировать ошибку и продолжить работу?
_Включаем data_checksums_
```
root@postgres:/usr/lib/postgresql/15/bin# pg_ctlcluster 15 main stop
root@postgres:/usr/lib/postgresql/15/bin# sudo su root -c '/usr/lib/postgresql/15/bin/pg_checksums --enable -D "/var/lib/postgresql/15/main"'
Checksum operation completed
Files scanned:   946
Blocks scanned:  2807
Files written:  778
Blocks written: 2807
pg_checksums: syncing data directory
pg_checksums: updating control file
Checksums enabled in cluster
root@postgres:/usr/lib/postgresql/15/bin# pg_ctlcluster 15 main start
```
_Создаем и наполняем таблицу_
```sql
postgres=# create table test(value1 integer, value2 char(100));
CREATE TABLE
postgres=#
postgres=#
postgres=# insert into test values (1, 'test123');
INSERT 0 1
postgres=# insert into test values (2, 'test312');
INSERT 0 1

postgres=# SELECT pg_relation_filepath('test');
 pg_relation_filepath
----------------------
 base/5/16388
(1 row)
```
_Останавливаем клистер, меняем содержимое файла, запускаем кластер_
```
postgres@postgres:/usr/lib/postgresql/15/bin$ pg_ctlcluster 15 main stop
postgres@postgres:/usr/lib/postgresql/15/bin$ dd if=/dev/zero of=/var/lib/postgresql/15/main/base/5/16388 oflag=dsync conv=notrunc bs=1 count=8
postgres@postgres:/usr/lib/postgresql/15/bin$ pg_ctlcluster 15 main start
```
_Делаем запрос к таблице_
```sql
postgres=# select * from test;
WARNING:  page verification failed, calculated checksum 41681 but expected 27102
ERROR:  invalid page in block 0 of relation base/5/16388
```
_Получили ошибку, так как не сошлись реальная и ожидаемая чексуммы из-за ручных изменений в файле с таблицей._
_Чтобы ошибки не было нужно установить параметр ignore_checksum_failure = on_
```sql
postgres=# set ignore_checksum_failure = 'on';
SET
postgres=# show ignore_checksum_failure;
 ignore_checksum_failure
-------------------------
 on
(1 row)

postgres=# select * from test;
WARNING:  page verification failed, calculated checksum 41681 but expected 27102
 value1 |                                                value2
--------+------------------------------------------------------------------------------------------------------
      1 | test123
      2 | test312
(2 rows)
```