#!/bin/bash

http_id=`hostname -i`
hn=`hostname`
http_post=`cat /etc/httpd/conf/httpd.conf |grep "Listen " |grep -v "#" |awk '{print $2}'`

#ambari-server主机参数优化（包括THP、防火墙、设置ssh免密码登录、安装jdk等）
./init_centos6.sh -hostname $hn -yum_baseurl http://$http_id:$http_post/sugo_yum

#将/root/.ssh/id_rsa.pub放到yum源目录下的SG/Centos6/1.0/:
rm -rf /var/www/html/sugo_yum/SG/centos6/1.0/id_rsa.pub
cp /root/.ssh/id_rsa.pub /var/www/html/sugo_yum/SG/centos6/1.0/

#其它主机上的参数优化
./init_all_hosts.sh

#将ambari-server主机上的公钥加入到authorized_keys文件
<<<<<<< be84710ea5baab982b6bb4d379b02383b7c86a91:ambari_server_inst/os/init_process.sh
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
=======
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

#删除/etc/ip.txt文件
rm -f /etc/ip.txt
>>>>>>> b810e6338bf59674e26fb9b0d1a901034ae56e92:ambari_server_inst/os/init_process.sh
