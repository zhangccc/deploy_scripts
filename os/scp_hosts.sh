#!/bin/bash

#安装相关软件
yum install -y wget 
yum install -y ntp
yum install -y openssh-clients
yum install -y unzip
yum install -y expect

#关闭防火墙和seLinux
chkconfig iptables off
/etc/init.d/iptables stop
setenforce 0


cat ./ip.txt|while read line;
do
hn=`echo $line|awk '{print $1}'`
pw=`echo $line|awk '{print $2}'`

/usr/bin/expect <<-EOF
set timeout 100000
spawn scp -r /etc/hosts root@$hn:/etc/
	expect {
	"*yes/no*" { send "yes\n"
	expect "*assword:" { send "$pw\n" } }
	"*assword:" { send "$pw\n" } 
	}
	expect "*]#*"
EOF
done