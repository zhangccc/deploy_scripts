#!/bin/bash

#端口号--$1
#安装包路径--$2
#日志、元数据存储目录 --$3

#安装yum源
./sugo_yum_inst.sh $1 $2

#创建元数据存储目录
cd ../os
./create_datadir.sh $3

#分发hosts文件
./scp_hosts.sh

#初始化主机
./init_process.sh

#安装ambari-server
cd ../ambari-server
./ambari_server_inst.sh
