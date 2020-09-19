#!/bin/bash
VAR="eth0"
HOST_IP=$(ifconfig $VAR | grep "inet" | awk '{ print $2}')
echo $HOST_IP
