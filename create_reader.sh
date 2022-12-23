#!/bin/bash
queue=wl_dnn_joiner_blink_exp_na61prod3
user=xiazhigang.xzg

reader=wl_reader_
fetch_type=1
srv=COFFLINE

extra=

num=`expr $1 - 1`
for i in `seq 0 $num`
do
  # queue=$queues$i
  # echo $queue
  readers=$reader$i
  echo $readers
  echo ./new_mq_tools_mgr --key=MQ@MGR --cluster=$srv --logtostderr --op=create_reader --mq_user=$user --queue=$queue --reader=$readers --fetch_type=$fetch_type $extra
  # ./new_mq_tools_mgr --key=MQ@MGR --cluster=$srv --logtostderr --op=create_reader --mq_user=$user --queue=$queue --reader=$readers --fetch_type=$fetch_type $extra
done