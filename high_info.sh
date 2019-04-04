#!/bin/bash
#description 抓取凌晨1点多负载过高时的信息

memstatus=$(free -m | sed -n '3p' | awk '{print ""$3/16000*100""}')
mem_status=$(echo $memstatus | awk -F'[.]'  '{print $1}')
echo $mem_status
max=85
if [ $mem_status -gt $max ];then
    top -n1 -b >> /OpsScript/logs/high.log
    echo "--------memory top 10---------" >> /OpsScript/logs/high.log
    ps -e -o 'pid,comm,pcpu,rsz,vsz,stime,user,args' |sort -nrk4 | head -10 >> /OpsScript/logs/high.log
    echo "___________________________________" >> /OpsScript/logs/high.log
fi

load1=$(uptime | awk -F'[, ]+' '{print $11*100}')
echo $load1
if [ $load1 -gt 400 ];then
    top -n1 -b >> /OpsScript/logs/high.log
    echo "--------CPU top 10---------" >> /OpsScript/logs/high.log
    ps -e -o 'pid,comm,pcpu,rsz,vsz,stime,user,args' |sort -nrk3 | head -10 >> /OpsScript/logs/high.log
    echo "___________________________________" >> /OpsScript/logs/high.log
fi
