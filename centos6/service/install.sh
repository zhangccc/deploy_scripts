#!/bin/bash

if [ $1 -eq "-h" ] || [$1 -eq "-help" ];then
    echo 'usage : ./install $httpd_port $server_IP $cluster_name'
    exit
fi

sort ../ambari-server/host > ../ambari-agent/host

namenode1=`cat ../ambari-agent/host | sed -n "1p" |awk '{print $2}'`
namenode2=`cat ../ambari-agent/host | sed -n "2p" |awk '{print $2}'`
datanode1=`cat ../ambari-agent/host | sed -n "3p" |awk '{print $2}'`

sed -i "s/dev220.sugo.net/${namenode1}/g" host_service.json
sed -i "s/dev221.sugo.net/${namenode2}/g" host_service.json
sed -i "s/dev222.sugo.net/${datanode1}/g" host_service.json


httpd_port=$1
server_IP=$2
cluster_name=$3

httpd_service=`netstat -ntlp | grep $httpd_port | grep httpd`
if [ $httpd_service = "" ];then
echo "service httpd not running, please start it first!"
exit
fi

#判断ambari-server是否已经启动，如果没有，则等待启动完成
ambari=`netstat -ntlp | grep 8080`
while [ "$ambari" = "" ]
do
  ambari=`netstat -ntlp | grep 8080`
  if [ "$ambari" = "" ];then
    echo "waiting for ambari-server to start~~~"
    sleep 1
    continue
  else
    break
  fi
done

#创建集群、更新基础url，安装注册ambari-agent
./install_cluster.sh $httpd_port $server_IP $cluster_name
sleep 2

#重启ambari
#ambari-server restart

#安装服务
python install_service.py $cluster_name $server_IP
