#!/bin/sh

if [[ $1 == 'mq' ]]; then
  grep ip_local_port_range /etc/rc.local
  if [ $? -ne 0 ]; then
    echo 'echo "32768   61000" > /proc/sys/net/ipv4/ip_local_port_range'
  fi

  grep tcp_tw_reuse /etc/rc.local
  if [ $? -ne 0 ]; then
    echo 'echo 1 >  /proc/sys/net/ipv4/tcp_tw_reuse'
  fi

  grep tcp_tw_recycle /etc/rc.local
  if [ $? -ne 0 ]; then
    echo 'echo 1 > /proc/sys/net/ipv4/tcp_tw_recycle'
  fi

  df -Th|grep data10
  if [ $? -ne 0 ]; then
    echo 'echo 1 > /proc/sys/net/ipv4/tcp_tw_recycle'
  fi

  df -Th|grep data12
  if [ $? -eq 0 -a -d /data12 ];then
    link_path='/data12'
  else
    link_path='/logging'
  fi
  echo $link_path
fi
