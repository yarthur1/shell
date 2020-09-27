#!/bin/bash

# 毫秒级   https://www.cnblogs.com/f-ck-need-u/p/7426987.html

function timediff() {

# time format:date +"%s.%N", such as 1502758855.907197692
    start_time=$1
    end_time=$2
    
    start_s=${start_time%.*}
    start_nanos=${start_time#*.}
    end_s=${end_time%.*}
    end_nanos=${end_time#*.}
    
    # end_nanos > start_nanos? 
    # Another way, the time part may start with 0, which means
    # it will be regarded as oct format, use "10#" to ensure
    # calculateing with decimal
    if [ "$end_nanos" -lt "$start_nanos" ];then
        end_s=$(( 10#$end_s - 1 ))
        end_nanos=$(( 10#$end_nanos + 10**9 ))
    fi
    
# get timediff
    time=$(( 10#$end_s - 10#$start_s )).`printf "%03d\n" $(( (10#$end_nanos - 10#$start_nanos)/10**6 ))`
    
    echo $time >> ./stats.log
}


# day=10
# month=10
# if [ "$day" -eq "30" ]
# then
#     day=10
# fi

# day=`expr $day + 1`;
# echo $day
months="01 02 03 04 05 06 07 08"

for i in $(seq 1 1000)  
do   
    for year in $(seq 2016 2019)  
    do   
        for mon in $months
        do   
            for day in $(seq 10 28)  
            do   
                start=$(date +"%s.%N")

                mysql -h 10.66.125.17 -u root -P 4000 -D livemefinance --comments -e "
                SELECT /*+ READ_FROM_STORAGE(TIFLASH[send_gift_log_all]) */ sender,sum(sender_price) AS price FROM send_gift_log_all
                WHERE ((date >= '2020-01-01') AND (date <= '2020-12-30')) AND ((mtime >= '2020-"$mon"-01 12:00:00') AND (mtime <= '2020-"$mon"-"$day" 11:59:59')) AND (type IN (0, 2, 3, 7)) AND (gift_id IN (5740, 226, 6013, 8762, 12558, 12557, 5978, 11662, 7721, 6454, 1472, 6439)) AND (alias IN ('us', 'ar', 'liveme', '')) GROUP BY sender ORDER BY price DESC LIMIT 20;
                " >/dev/null

                end=$(date +"%s.%N")
                timediff $start $end
            done
        done
    done
done   