#!/bin/bash

httpid=`hostname -i`
hn=`hostname`
httppost=`cat /etc/httpd/conf/httpd.conf |grep "Listen " |grep -v "#" |awk '{print $2}'`

#下载相关脚本并赋予执行权限
wget http://$httpid:$httppost/sugo_yum/SG/centos6/1.0/init_centos6.sh
wget http://$httpid:$httppost/sugo_yum/SG/centos6/1.0/auto_ssh.sh
wget http://$httpid:$httppost/sugo_yum/SG/centos6/1.0/ip.txt
chmod 755 init_centos6.sh auto_ssh.sh

#ambari-server主机参数优化（包括THP、防火墙、设置ssh免密码登录、安装jdk等）
./init_centos6.sh -hostname $hn -yum_baseurl http://$httpid:$httppost/sugo_yum

#将/root/.ssh/id_rsa.pub放到yum源目录下的SG/Centos6/1.0/:
rm -rf /var/www/html/sugo_yum/SG/centos6/1.0/id_rsa.pub
cp ~/.ssh/id_rsa.pub /var/www/html/sugo_yum/SG/centos6/1.0

#其它主机上的参数优化
./auto_ssh.sh

#将ambari-server主机上的公钥加入到authorized_keys文件
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

#删除相关脚本文件
rm -rf auto_ssh.sh init_centos6.sh ip.txt init.sh



