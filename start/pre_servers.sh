#!/bin/bash

./sugo_yum_inst.sh $1 $2

cd /root/deploy_scripts/os
./create_datadir.sh $3

./scp_hosts.sh

cd /root/deploy_scripts/os
./init_process.sh

cd ../ambari-server
./ambari_server_inst.sh
