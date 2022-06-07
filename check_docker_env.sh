#!/bin/sh

osChange="false"
needReboot="false"
#检查内核版本
kernel_version="3.10.0-327.ali2014.alios7.x86_64"
if [ `uname -r` !=  "$kernel_version" ]; then
  echo "Upgrading kernel to $kernel_version ..."
  yum  --enablerepo=taobao.7.x86_64.stable --enablerepo=taobao.7.noarch.stable install -y kernel-"$kernel_version" kernel-devel-"$kernel_version"
  yum install -y http://yum.tbsite.net/taobao/7/x86_64/current/kernel-hotfix-D902239-ali2014/kernel-hotfix-D902239-ali2014-1.0-4.alios7.x86_64.rpm
  osChange="true"
fi

# 特殊环境初始化
link_path=''
dst_path='/serving'

if [[ $1 == 'oldb' ]]; then
  link_path='/app/serving'

  # 初始化环境
  wget http://ctl.sm.alibaba-inc.com/sysctl.conf -O /etc/sysctl.conf
  needReboot="true"
fi

if [[ $1 == 'mq' ]]; then
  grep ip_local_port_range /etc/rc.local
  if [ $? -ne 0 ]; then
    echo 'echo "32768   61000" > /proc/sys/net/ipv4/ip_local_port_range' >> /etc/rc.local
  fi

  grep tcp_tw_reuse /etc/rc.local
  if [ $? -ne 0 ]; then
    echo 'echo 1 >  /proc/sys/net/ipv4/tcp_tw_reuse' >> /etc/rc.local
  fi

  grep tcp_tw_recycle /etc/rc.local
  if [ $? -ne 0 ]; then
    echo 'echo 1 > /proc/sys/net/ipv4/tcp_tw_recycle' >> /etc/rc.local
  fi

  df -Th|grep data10
  if [ $? -ne 0 ]; then
    echo 'no data10 disk'
  fi

  df -Th|grep data12
  if [ $? -eq 0 -a -d /data12 ];then
    link_path='/data12'
  else
    link_path='/logging'
  fi
fi

if [[ ${link_path} != '' ]]; then

  if [[ ! -d ${link_path} ]]; then
    mkdir ${link_path}
  fi

  if [[ -h ${dst_path} ]]; then
    cur_link_path=`readlink ${dst_path}`
    # 如果是物理文件夹或者软链的目录不对，备份
    if [[ ${cur_link_path} != ${link_path} ]]; then
       mv ${dst_path} ${dst_path}.bak
       ln -snf ${link_path} ${dst_path}
    fi
  else
    ln -snf ${link_path} ${dst_path}
  fi
fi

if [[ $1 == 'mq' ]]; then
  for i in $(seq 1 11);do rm -rf /data$i/message_queue_server/message_data;done 
fi

# 检查ibrs是否关闭，开启会影响性能
grep noibrs /etc/default/grub
ret=$?
if [ $ret = 1 ]; then
  echo "ibrs need change"
  sed -i  '/GRUB_CMDLINE_LINUX/s/"/&noibrs noibpb /' /etc/default/grub
  grub2-mkconfig -o /boot/grub2/grub.cfg
  needReboot="true"
fi

if [ $osChange = "true" -o $needReboot = "true" ]; then
  echo "shutdown machine now"
  shutdown -r now
  exit
fi