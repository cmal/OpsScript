#!/usr/bin/env python
# -*- coding: utf-8 -*-
'''
发送html文本邮件
'''
import sys
import smtplib
from email.mime.text import MIMEText
mailto_list="yudong.jin@joudou.com"
mail_host="smtp.mxhichina.com"  #设置服务器
mail_port=25
mail_user="internal.notification@joudou.com"    #用户名
mail_pass="7d7AxnyNJCirKn"   #口令
mail_postfix="joudou.com"  #发件箱的后缀

def send_mail(to_list,sub,content):  #to_list：收件人；sub：主题；content：邮件内容
    me="Joudou-Workflow"+"<"+mail_user+"@"+mail_postfix+">"   #这里的hello可以任意设置，收到信后，将按照设置显示
    msg = MIMEText(content,_subtype='html',_charset='utf-8')    #创建一个实例，这里设置为html格式邮件
    msg['Subject'] = sub    #设置主题
    msg['From'] = me
    msg['To'] = to_list
    #msg['To'] = ";".join(to_list)
    try:
        #s = smtplib.SMTP()
        #s.connect(mail_host,mail_port)  #连接smtp服务器

        s = smtplib.SMTP_SSL(mail_host, 465)

        s.login(mail_user,mail_pass)  #登陆服务器
        s.sendmail(me, to_list, msg.as_string())  #发送邮件
        s.close()
        return True
    except Exception, e:
        print str(e)
        return False

if __name__ == '__main__':
    if send_mail(mailto_list,sys.argv[1],sys.argv[2]):
        print "发送成功"
    else:
        print "发送失败"
