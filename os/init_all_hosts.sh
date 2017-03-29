#!/bin/bash

http_post=`cat /etc/httpd/conf/httpd.conf |grep "Listen " |grep -v "#" |awk '{print $2}'`
http_id=`hostname -i`

cat /etc/ip.txt|while read line;
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
	}
		expect "*#*"
	send "wget http://$http_id\:$http_post/sugo_yum/SG/centos6/1.0/init_centos6.sh\n"
        expect "*#*"
	send "chmod 755 init_centos6.sh\n"
        expect "*#*"
	send "./init_centos6.sh -hostname $hn -yum_baseurl http://$http_id\:$http_post/sugo_yum\n"
	send "rm -rf init_centos6.sh\r"
		expect "*]#*"
EOF
done