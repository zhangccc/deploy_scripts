#!/bin/bash
#如果客户已创建/data目录且位于较大磁盘分区下，则通过符号链接减少磁盘占用

if [ "$1" = "" ]
then
	mkdir /data1 /data2

	cat ./ip.txt |while read line;
	do
	hn=`echo $line|awk '{print $1}'`
	pw=`echo $line|awk '{print $2}'`
	
	/usr/bin/expect <<-EOF
	spawn ssh $hn
		expect {
		"*yes/no*" { send "yes\n"
		expect "*assword:" { send "$pw\n" } }
		"*assword:" { send "$pw\n" } 
		}
			expect "*#*"
		send "mkdir /data1 /data2\n"
			expect "*#*"
	EOF
	done

else
	mkdir $1/data1 $1/data2
	ln -s $1/data1 /data1
	ln -s $1/data2 /data2
	
	cat ./ip.txt |while read line;
	do
	hn=`echo $line|awk '{print $1}'`
	pw=`echo $line|awk '{print $2}'`
	
	/usr/bin/expect <<-EOF
	spawn ssh $hn
		expect {
		"*yes/no*" { send "yes\n"
		expect "*assword:" { send "$pw\n" } }
		"*assword:" { send "$pw\n" } 
		}
			expect "*#*"
		send "mkdir $1/data1 $1/data2\n"
			expect "*#*"
		send "ln -s $1/data1 /data1\n"
			expect "*#*"
		send "ln -s $1/data2 /data2\n"
			expect "*#*"
	EOF
	done

fi