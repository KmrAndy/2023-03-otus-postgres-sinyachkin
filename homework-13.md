# Домашнее задание
## Триггеры, поддержка заполнения витрин

### Цель:
- Создать триггер для поддержки витрины в актуальном состоянии.

### Описание/Пошаговая инструкция выполнения домашнего задания:
- Скрипт и развернутое описание задачи – в ЛК (файл hw_triggers.sql) или по ссылке: https://disk.yandex.ru/d/l70AvknAepIJXQ
- В БД создана структура, описывающая товары (таблица goods) и продажи (таблица sales).
- Есть запрос для генерации отчета – сумма продаж по каждому товару.
- БД была денормализована, создана таблица (витрина), структура которой повторяет структуру отчета.
1) Создать триггер на таблице продаж, для поддержки данных в витрине в актуальном состоянии (вычисляющий при каждой продаже сумму и записывающий её в витрину)
Подсказка: не забыть, что кроме INSERT есть еще UPDATE и DELETE
_Создал триггерную функцию и триггер на таблице sales:_
```sql
CREATE OR REPLACE FUNCTION pract_functions.fill_datamart()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare
  v_current_sales_sum good_sum_mart.sum_sale%type;
  v_new_sales_sum     good_sum_mart.sum_sale%type;
  v_good_price	      goods.good_price%type;
  v_good_name		  goods.good_name%type;
  v_data_row 		  record;
begin
  -- Получим текущую сумму продаж товара и текущую цену товара
  select coalesce(gsm.sum_sale, 0), g.good_price, g.good_name 
    into v_current_sales_sum, v_good_price, v_good_name
    from goods g
    left join good_sum_mart gsm on gsm.good_name = g.good_name
   where g.goods_id = coalesce(new.good_id, old.good_id);
  
  -- Для вставки добавляем к текущему значению
  -- Для обновления вычитаем старое значение из текущего и добавляем новое
  -- Для удаления вычитаем старое значение из текущего значения
  case TG_OP
    when 'INSERT' then
      v_new_sales_sum := v_current_sales_sum + new.sales_qty * v_good_price;
      v_data_row      := new;
    
    when 'UPDATE' then
      v_new_sales_sum := v_current_sales_sum - old.sales_qty * v_good_price + new.sales_qty * v_good_price;
      v_data_row      := new;
    
    when 'DELETE' then
      v_new_sales_sum := v_current_sales_sum - old.sales_qty * v_good_price;
      v_data_row      := old;
  end case;
     
  -- Обновляем витрину
  merge into good_sum_mart gsm
  using (select v_good_name as good_name, v_new_sales_sum as new_sales_sum) t
  on t.good_name = gsm.good_name 
  when matched then
    update set sum_sale = t.new_sales_sum
  when not matched then
    insert (good_name, sum_sale)
    values (t.good_name, t.new_sales_sum);
     
  return v_data_row;
end;
$function$
;

CREATE or REPLACE TRIGGER trg_fill_datamart
AFTER
INSERT OR UPDATE OR DELETE
ON pract_functions.sales
FOR EACH ROW
EXECUTE FUNCTION pract_functions.fill_datamart();
```

_Проверим текущую сумму продаж в витрине товара "Спички хозайственные"(good_id = 1):_
```sql
select gsm.*
  from goods g
  join good_sum_mart gsm on g.good_name = gsm.good_name
 where g.goods_id = 1;

good_name|sum_sale|
---------+--------+
```
_Значений в витрине нет. Добавим новую продажу:_
```sql
INSERT INTO sales (good_id, sales_qty) VALUES (1, 30);
```

_В витрине появилось новое значение (сумма 15, так как цена 1 спички - 0.5, а продали их 30):_
```sql
good_name           |sum_sale|
--------------------+--------+
Спички хозайственные|   15.00|
```

_Добавим ещё одну новую продажу:_
```sql
INSERT INTO sales (good_id, sales_qty) VALUES (1, 100);
```

_Витрина:_
```sql
good_name           |sum_sale|
--------------------+--------+
Спички хозайственные|   65.00|
```

_Сделаем обновление последней продажи - изменим количество со 100 на 50:_
```sql
update sales set sales_qty = 50 where sales_id = 10;
```

_Витрина:_
```sql
good_name           |sum_sale|
--------------------+--------+
Спички хозайственные|   40.00|
```

_То есть сумма скорректировалась, убрали 50 спичек, то есть 25 условных единиц. Было 65 - стало 40._

_Сделаем удаление последней уже скорректированной продажи:_
```sql
delete from sales where sales_id = 10;
```

_Витрина:_
```sql
good_name           |sum_sale|
--------------------+--------+
Спички хозайственные|   15.00|
```

_Витрина вернулась в состояние, до создания продажи с id = 10._

2) Чем такая схема (витрина+триггер) предпочтительнее отчета, создаваемого "по требованию" (кроме производительности)?
Подсказка: В реальной жизни возможны изменения цен.

_1) Схема "витрина + триггер" гарантирует актуальность данных в витрине практически на лету при минимальных затратах сервера. Отчёт не будем перестраивать каждую минуту, даже если отчёт с инкрементальной загрузкой._
_Но в больших БД лучше, конечно, не делать синхронную обработку изменений в витрине и лучше использовать какие-то очереди или таблицы для хранения изменений, которые потом будет обрабатывать фоновый процесс и обновлять витрину._
_2) В текущей реализации триггера при изменении цены будут потери суммы продаж при обновлении или удалении продажи, так как мы не сможем вычислить сумму продажи по старой цене._
_Чтобы этого избежать должна быть отдельная таблица "Прайслист", в которой будет храниться история цены для каждого товара._
_В этом случае при обновлениях и удалениях сможем взять актуальную цену на момент продажи и сделать правильную корректировку суммы продаж в витрине_

