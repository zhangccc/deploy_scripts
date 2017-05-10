#!/bin/bash

#端口号--$1
#安装包路径--$2
#日志、元数据存储目录 --$3
#$4 -- ambari-server的IP

#安装yum源
./sugo_yum_inst.sh $1 $2
echo "~~~~~~~~~~~~yum installed~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

#创建元数据存储目录
cd ../os
./create_datadir.sh $3

echo "~~~~~~~~~~~~directory has been created~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
#分发hosts文件
./scp_hosts.sh
echo "~~~~~~~~~~~~hosts file has been coped~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

#初始化主机
./init_process.sh $4
echo "~~~~~~~~~~~init centos finished~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

#安装ambari-server
cd ../ambari-server
./ambari_server_inst.sh
