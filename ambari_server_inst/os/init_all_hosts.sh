#!/bin/bash
#$1 -- ambari-server的IP

http_post=`cat /etc/httpd/conf/httpd.conf |grep "Listen " |grep -v "#" |awk '{print $2}'`


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
	"*]#*" { send "wget http://$1:$http_post/sugo_yum/deploy_scripts/ambari_server_inst/os/init_centos6.sh\n" }
	"*]#*" { send "chmod 755 init_centos6.sh\n" }
	"*]#*" { send "./init_centos6.sh -yum_baseurl http://$1:$http_post/sugo_yum\n" }
	"*]#*" { send "rm -rf init_centos6.sh\n" }
	"*]#*"
	}
		expect "*]#*"
	send "wget http://$1:$http_post/sugo_yum/deploy_scripts/ambari_server_inst/os/init_centos6.sh\n"
		expect "*]#*" 
	send "chmod 755 init_centos6.sh\n"
		expect "*]#*" 
	send "./init_centos6.sh -yum_baseurl http://$1:$http_post/sugo_yum\n"
		expect "*]#*" 
	send "rm -rf init_centos6.sh*\n"
		expect "*]#*"
EOF
done