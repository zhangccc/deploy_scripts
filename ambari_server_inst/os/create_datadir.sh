#!/bin/bash
#如果客户已创建/data目录且位于较大磁盘分区下，则通过符号链接减少磁盘占用

#日志、元数据存储目录--$1

if [ $1 == "" ]
then
	mkdir /data1 /data2
	
	echo "存储主目录未设定，数据将直接保存在/data1 和 /data2 目录中"
	
	cat /etc/ip.txt |while read line;
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
			expect "*]#*" 
		{ send "mkdir /data1 /data2\n" }
			expect "*]#*" 
		send "yum install -y wget ntp openssh-clients\n"
			expect "*]#*" 
		send "service ntpd start\n"
			expect "*]#*"
		}
			expect "*#*" 
		send "mkdir /data1 /data2\n"
			expect "*]#*" 
		send "yum install -y wget ntp openssh-clients\n"
			expect "*]#*" 
		send "service ntpd start\n"
			expect "*]#*"
	EOF
	done

else

	mkdir -p $1/data1 $1/data2 
	ln -s $1/data1 /data1
	ln -s $1/data2 /data2
	
	cat /etc/ip.txt |while read line;
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
		"*]#*" { send "mkdir -p $1/data1 $1/data2\n" }
			expect "*]#*" 
		send "ln -s $1/data1 /data1\n" 
			expect "*]#*" 
		send "ln -s $1/data2 /data2\n"
			expect "*]#*" 
		send "yum install -y wget ntp openssh-clients\n"
			expect "*]#*" 
		send "service ntpd start\n"
			expect "*]#*"
		}
			expect "*]#*" 
		send "mkdir -p $1/data1 $1/data2\n"
			expect "*]#*" 
		send "ln -s $1/data1 /data1\n"
			expect "*]#*" 
		send "ln -s $1/data2 /data2\n"
			expect "*]#*"
		send "mkdir /data1 /data2\n"
			expect "*]#*" 
		send "yum install -y wget ntp openssh-clients\n"
			expect "*]#*" 
		send "service ntpd start\n"
			expect "*]#*"
	EOF
	done
fi
