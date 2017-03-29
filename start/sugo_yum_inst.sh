#!/bin/bash


#ambari-server主机安装相关软件及http服务
yum install -y wget
yum install -y ntp
yum install -y openssh-clients
yum install -y unzip
yum install -y expect
yum install -y httpd

#关闭防火墙和seLinux
chkconfig iptables off
/etc/init.d/iptables stop
setenforce 0

#修改http端口号
sed -i "s/`cat /etc/httpd/conf/httpd.conf |grep "Listen " |grep -v "#" |awk '{print $2}'`/${1}/" /etc/httpd/conf/httpd.conf

#解压缩yum源文件
cd $2
unzip $2/sugo_yum.zip

#创建软连接
ln -s $2/sugo_yum /var/www/html

#开启http服务
service httpd start

cd
wget http://`hostname`:$1/sugo_yum/SG/centos6/1.0/deploy_scripts.tar.gz
wget http://`hostname`:$1/sugo_yum/SG/centos6/1.0/init_process.sh
chmod 755 init_process.sh
tar -zxvf deploy_scripts.tar.gz
cd deploy_scripts/os
chmod 755 * 
cd ../servers
chmod 755 ambari_server_inst.sh
