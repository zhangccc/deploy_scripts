#!/bin/bash


### set hostname
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
    { send "hostname $hn\n" }
        "*]#*"
    { send "sed -i 's/HOSTNAME=.*/HOSTNAME=${hn}/g' /etc/sysconfig/network\n" }
        "*]#*"
    }
        expect "*]#*"
    send "hostname $hn\n"
        expect "*]#*"
    send "sed -i 's/HOSTNAME=.*/HOSTNAME=${hn}/g' /etc/sysconfig/network\n"
        expect "*]#*"
EOF
done

