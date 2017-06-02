#!/bin/bash

#配置ssh免密码登录
yum_baseurl=$1

rm -rf /root/.ssh
ssh-keygen -t rsa -P ''<< EOF
/root/.ssh/id_rsa
EOF

pub_key=`curl "${yum_baseurl}/SG/centos6/1.0/id_rsa.pub"`

res=`grep "$pub_key" /root/.ssh/authorized_keys`
if [ "$res" = "" ]
then
 echo $pub_key >>  /root/.ssh/authorized_keys
fi

