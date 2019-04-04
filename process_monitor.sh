#!/bin/bash

source /etc/profile

####define $IP $DATE
IP=$(ifconfig eth1|awk '{if(NR==2)print $0}'|awk -F "[ :]+" '{print $4}')
DATE=$(date "+%F %H:%M:%S")
####check web_process_status
wxstatus=$(ps aux | grep "jdweixin" | grep -E -v "grep" | wc -l)
if [ $wxstatus -lt 1 ];then
    echo "#####################$DATE $IP##########################" >> /home/works/OpsScript/logs/pro_status.txt
    echo "warn : www jdweixin is not runing " >> /home/works/OpsScript/logs/pro_status.txt
    python /OpsScript/sendmail.py "check_wx_status" "$DATE \t $IP \t warn : www jdweixin process is not runing"
fi

stockstatus=$(ps aux | grep "stockinfo_gate" | grep "websvc" | grep -E -v "grep" | wc -l)
if [ $stockstatus -lt 1 ];then
    echo "#####################$DATE $IP##########################" >> /home/works/OpsScript/logs/pro_status.txt
    echo "warn : www stockinfo_gate is not runing " >> /home/works/OpsScript/logs/pro_status.txt
    log=$(ls /home/works/apps/stockinfo-gate/websvc.log-$(date +%Y%m%d) | wc -l)
    if [ $log -ne 1 ];then
        tail -500 /home/works/apps/stockinfo-gate/websvc.log >> /home/works/apps/stockinfo-gate/websvc_err.log
    else
        tail -500 /home/works/apps/stockinfo-gate/websvc.log-$(date +%Y%m%d) >> /home/works/apps/stockinfo-gate/websvc_err.log
    fi

    echo "$DATE start stockinfo-gate" >> /home/works/OpsScript/logs/start_stock.log 
    cd /home/works/apps/stockinfo-gate/ 
    /bin/sh websvc_start.sh 

    sleep 3
    run_status=$(ps aux | grep "stockinfo_gate" | grep "websvc" | grep -E -v "grep" | wc -l)
    if [ $run_status -lt 1 ];then
        echo "$DATE start failed" >> /OpsScript/logs/start_stock.log
        python /OpsScript/sendmail.py "[error] check_stockinfo_gate_status [$DATE]" "$DATE \t $IP \t warn : www stockinfo_gate process is not runing , process startup failure"
    else
        echo "$DATE start successful" >> /OpsScript/logs/start_stock.log
        python /OpsScript/sendmail.py "[ok] check_stockinfo_gate_status [$DATE]" "$DATE \t $IP \t warn : www stockinfo_gate process is not runing , process startup successful"
    fi

fi
