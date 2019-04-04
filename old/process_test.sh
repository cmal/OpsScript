#!/bin/bash
####define $IP $DATE
IP=$(ifconfig eth1|awk '{if(NR==2)print $0}'|awk -F "[ :]+" '{print $4}')
DATE=$(date "+%F %H:%M:%S")
####check web_process_status
wxstatus=$(ps aux | grep "jdweixin" | grep -E -v "grep" | wc -l)
if [ $wxstatus -ge 1 ];then
    echo "#####################$DATE $IP##########################" >> /OpsScript/pro_status.txt
    echo "warn : www jdweixin is not runing " >> /OpsScript/pro_status.txt
    python /OpsScript/sendmail-test.py "check_wx_status" "$DATE \t $IP \t warn : www jdweixin process is not runing"
fi

uastatus=$(ps aux | grep "useraction" | grep -E -v "grep" | wc -l)
if [ $uastatus -ge 1 ];then
    echo "#####################$DATE $IP##########################" >> /OpsScript/pro_status.txt
    echo "warn : www useraction is not runing " >> /OpsScript/pro_status.txt
    python /OpsScript/sendmail-test.py "check_useraction_status" "$DATE \t $IP \t warn : www useraction process is not runing"
fi

stockstatus=$(ps aux | grep "stockinfo_gate" | grep "websvc" | grep -E -v "grep" | wc -l)
echo $stockstatus
if [ $stockstatus -ge 1 ];then
    echo "#####################$DATE $IP##########################" >> /OpsScript/pro_status.txt
    echo "warn : www stockinfo_gate is not runing " >> /OpsScript/pro_status.txt
    log=$(ls /home/works/apps/stockinfo-gate/websvc.log-$(date +%Y%m%d) | wc -l)
    if [ $log -ne 1 ];then
        tail -500 /home/works/apps/stockinfo-gate/websvc.log >> /home/works/apps/stockinfo-gate/websvc_err.log
    else
        tail -500 /home/works/apps/stockinfo-gate/websvc.log-$(date +%Y%m%d) >> /home/works/apps/stockinfo-gate/websvc_err.log
    fi
    #/bin/sh /home/works/apps/stockinfo-gate/websvc_start.sh
    echo "$DATE start stockinfo-gate" >> /OpsScript/logs/start_stock.log 
    #cd /home/works/apps/stockinfo-gate/
    #/bin/sh websvc_start.sh
    echo "执行启动操作"
    sleep 3
    run_status=$(ps aux | grep "stockinfo_gate" | grep "websvc" | grep -E -v "grep" | wc -l)
    echo $run_status
    if [ $run_status -ge 1 ];then
        echo "$DATE start failed" >> /OpsScript/logs/start_stock.log
    	python /OpsScript/sendmail-test.py "check_stockinfo_gate_status" "$DATE \t $IP \t warn : www stockinfo_gate process is not runing , process startup failure"
    fi
fi
