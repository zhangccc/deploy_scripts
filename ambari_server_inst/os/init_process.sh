#!/bin/bash
#$1 -- ambari-server的IP

hn=`hostname`
http_post=`cat /etc/httpd/conf/httpd.conf |grep "Listen " |grep -v "#" |awk '{print $2}'`

#ambari-server主机参数优化（包括THP、防火墙、设置ssh免密码登录、安装jdk等）
./init_centos6.sh -yum_baseurl http://$1:$http_post/sugo_yum

#将/root/.ssh/id_rsa.pub放到yum源目录下的SG/Centos6/1.0/:
rm -rf /var/www/html/sugo_yum/SG/centos6/1.0/id_rsa.pub
cp /root/.ssh/id_rsa.pub /var/www/html/sugo_yum/SG/centos6/1.0/

#其它主机上的参数优化
./init_all_hosts.sh $1

#将ambari-server主机上的公钥加入到authorized_keys文件
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

#删除/etc/ip.txt文件
rm -f /etc/ip.txt