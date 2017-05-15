#!/bin/bash

baseurl=$1
init_url=$baseurl/deploy_scripts/centos6/ambari_server_inst

#在ambari-server节点配置ssh
./ssh.sh $baseurl

#将/root/.ssh/id_rsa.pub放到yum源目录下的SG/Centos6/1.0/:
rm -rf ../../../SG/centos6/1.0/id_rsa.pub
cp /root/.ssh/id_rsa.pub ../../../SG/centos6/1.0/

cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

cat ip.txt|while read line;
do
hn=`echo $line|awk '{print $1}'`
pw=`echo $line|awk '{print $2}'`

/usr/bin/expect <<-EOF
set timeout 100000
spawn ssh $hn
        expect {
        "*yes/no*" { send "yes\n"
        expect "*assword:" { send "$pw\n" } }
        "*assword:" { send "$pw\n" }
        "*]#*"
        }
                expect "*]#*"
        send "wget $init_url/ssh.sh\n"
                expect "*]#*" 
        send "chmod 755 ssh.sh\n"
                expect "*]#*" 
        send "./ssh.sh $baseurl\n"
                expect "*]#*" 
        send "rm -rf ssh.sh*\n"
                expect "*]#*"
EOF
done
