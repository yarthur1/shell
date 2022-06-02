#!/bin/bash
sudo /sbin/sysctl -p
sudo swapoff -a
sudo modprobe toa

if [ -d /app ]; then sudo chown serving:admin /app; fi
if [ -d /data1 ]; then sudo chown serving:admin /data*; fi
if [ -d /flash1 ]; then sudo chown serving:admin /flash*; fi
if [ -d /logging ]; then sudo chown serving:admin /logging; fi
if [ -e /dev/nvme0n1 ]; then sudo ln -s /logging /serving; else ln -s /app /serving; fi
if [[ -d /data1 && -d /data11 ]]; then echo "ok"; elif [[ -d /data1 && ! -d /data11 ]]; then sudo ln -s /app /data11; else echo "igonre"; fi
