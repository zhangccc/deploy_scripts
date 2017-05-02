#!/bin/bash

#端口号--$1
#安装包路径--$2


#ambari-server主机安装相关软件及http服务
yum install -y wget
yum install -y ntp
yum install -y openssh-clients
yum install -y expect
yum install -y httpd

#关闭防火墙和seLinux
chkconfig iptables off
/etc/init.d/iptables stop
setenforce 0

#修改http端口号
sed -i "s/`cat /etc/httpd/conf/httpd.conf |grep "Listen " |grep -v "#" |awk '{print $2}'`/${1}/" /etc/httpd/conf/httpd.conf

#创建软连接
ln -s $2/sugo_yum /var/www/html

#开启http服务
service httpd start
