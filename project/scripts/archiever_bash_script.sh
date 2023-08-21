#!/bin/bash
timeslot=`date '+%Y%m%d%H%M'`
logfile="/var/lib/postgresql/15/arch/archiever_log/"$timeslot"_log.log"
touch $logfile
partitions_query="select distinct table_owner || '.' || partition_name as partition_name from project_schema.archiever_queue aq where aq.process_flag = 1;"
partitions_dump_list=`psql -p 5432 -U postgres -At -c "$partitions_query" project_main_db`

echo "Start archiving partitions " >> $logfile
for partition_name in $partitions_dump_list; do
        pg_dump -p 5432 -d project_main_db -U postgres --no-tablespaces --section=pre-data --section=data -t $partition_name | psql -p 5433 project_archive_db

        update_archiever_query="update project_schema.archiever_queue aq set process_flag = null, process_date = current_timestamp at time zone 'Europe/Moscow' where aq.process_flag = 1 and (aq.table_owner || '.' || partition_name) = '$partition_name';"
        psql -p 5432 -U postgres -At -c "$update_archiever_query" project_main_db
        echo "Partition $partition_name copied to archieve db" >> $logfile
done
echo "Finish archiving partitions " >> $logfile