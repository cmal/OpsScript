#!/bin/bash
#description:监控MySQL服务的TCP连接数，向阿里云监控发送两个值，ESTABLISHED和TCP_TOTAL
#netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'

established_num=$(netstat -n| grep "3306" | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'|awk '/^ESTAB/{print $2}')
echo $established_num

tcp_num=$(netstat -n | grep "3306" | awk '/^tcp/ {++N} END {print N}')
echo $tcp_num

#使用SDK向云监控传入4个参数，userid, 监控项名称，监控项值，字段信息
/usr/local/bin/cms_post.sh 1283436150128546 mysql_tcp_concatenon $established_num www_ESTABLISHED
/usr/local/bin/cms_post.sh 1283436150128546 mysql_tcp_concatenon $tcp_num www_MySQL_TCP
