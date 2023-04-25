# Домашнее задание
## Установка и настройка PostgteSQL в контейнере Docker

### Цель:
- установить PostgreSQL в Docker контейнере
- настроить контейнер для внешнего подключения

### Описание/Пошаговая инструкция выполнения домашнего задания:
1) создать ВМ с Ubuntu 20.04/22.04 или развернуть докер любым удобным способом
2) поставить на нем Docker Engine
3) сделать каталог /var/lib/postgres
4) развернуть контейнер с PostgreSQL 15 смонтировав в него /var/lib/postgresql
5) развернуть контейнер с клиентом postgres
6) подключится из контейнера с клиентом к контейнеру с сервером и сделать таблицу с парой строк
7) подключится к контейнеру с сервером с ноутбука/компьютера извне инстансов GCP/ЯО/места установки докера
8) удалить контейнер с сервером
9) создать его заново
10) подключится снова из контейнера с клиентом к контейнеру с сервером
11) проверить, что данные остались на месте
12) оставляйте в ЛК ДЗ комментарии что и как вы делали и как боролись с проблемами

Решение:
1) Создал ВМ c Ubuntu 22.04 LTS в Яндекс.Облаке. Старая ВМ с первого урока после запуска отказывалась пускать (permission denied даже под юзером ubuntu), пришлось пересоздавать с новым ключом.
2) Поставил докер, почему-то команда из урока сработала не с 1 раза. В первый раз просто зависла консоль и не вывела ни одну запись. Со 2 раза все установилось без проблем. Создал сеть pg-net.
```
curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh && rm get-docker.sh && sudo usermod -aG docker $USER
sudo docker network create pg-net
```
3) Создал каталог /var/lib/postgres. Прав у моего пользователя не было, но через sudo создал директорию.
```
sudo mkdir /var/lib/postgres
```
4) Развернул контейнер pg-server с PostgreSQL 15, смонтировал в него директорию postgres, привязал к сети pg-net.
Изначально вместо 15 версии поставил 14, удалил контейнер и имейдж из докера, запустил новый с 15 версией, но почему-то он он взлетел. Команда отрабатывала успешно, но контейнер не стартовал с ошибкой EXITED(1).
Возможно я что-то некорректно удалил в первый раз.
Побороть смог только пересозданием ВМ с последующей повторной установкой докера и созданием контейнера с 15 версией с первого раза.
```
sudo docker run --name pg-server --network pg-net -e POSTGRES_PASSWORD=postgres -d -p 5432:5432 -v /var/lib/postgres:/var/lib/postgresql/data postgres:15
```
5) Развернул контейнер с клиентом postgres pg-client
```
sudo docker run -it --rm --network pg-net --name pg-client postgres:15 psql -h pg-server -U postgres
```
6) Подключился из контейнера с клиентом pg-client к контейнеру с сервером pg-server, создал новую базу iso, сделал таблицу и вставил 2 записи
```sql
create database iso;
\c iso;
create table persons(id serial, first_name text, second_name text);
insert into persons(first_name, second_name) values('ivan', 'ivanov');
insert into persons(first_name, second_name) values('petr', 'petrov');
```
7) Установил постгрес на домашний комп, подключился с него к контейнеру c постгресом.
```
& 'C:\Program Files\PostgreSQL\15\bin\psql.exe' -p 5432 -U postgres -h 51.250.66.249 -d postgres -W
```
8) Остановил и удалил контейнер с сервером
```
sudo docker stop f79be2d0503b
sudo docker rm f79be2d0503b
```
9) Создал заново
```
sudo docker run --name pg-server --network pg-net -e POSTGRES_PASSWORD=postgres -d -p 5432:5432 -v /var/lib/postgres:/var/lib/postgresql/data postgres:15
```
10) Подключился из контейнера с клиентом к контейнеру с сервером
```
sudo docker run -it --rm --network pg-net --name pg-client postgres:15 psql -h pg-server -U postgres
```
11) Данные действительно остались на месте:
```
Password for user postgres:
psql (15.2 (Debian 15.2-1.pgdg110+1))
Type "help" for help.

postgres=# \l
                                                List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    | ICU Locale | Locale Provider |   Access privileges
-----------+----------+----------+------------+------------+------------+-----------------+-----------------------
 iso       | postgres | UTF8     | en_US.utf8 | en_US.utf8 |            | libc            |
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 |            | libc            |
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 |            | libc            | =c/postgres          +
           |          |          |            |            |            |                 | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 |            | libc            | =c/postgres          +
           |          |          |            |            |            |                 | postgres=CTc/postgres
(4 rows)

postgres=# \c iso;
You are now connected to database "iso" as user "postgres".
iso=# select * from persons;
 id | first_name | second_name
----+------------+-------------
  1 | ivan       | ivanov
  2 | petr       | petrov
(2 rows)
```