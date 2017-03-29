#!/bin/bash
function print_usage(){
  echo "Usage: init_centos6 [-options]"
  echo " where options include:"
  echo "     -help                  帮助文档"
  echo "     -hostname <hostname>   主机名"
  echo "     -yum_baseurl <url>     yum服务器根路径"
  echo "     -skip_ssh              不安装ssh密码"
  echo "     -skip_jdk              不安装jdk"
}

cd `dirname $0`
hostname=""
skip_ssh=0
skip_jdk=0
while [[ $# -gt 0 ]]; do
    case "$1" in
           -help)  print_usage; exit 0 ;;
       -hostname) hostname=$2 && shift 2 ;;
       -yum_baseurl) yum_baseurl=$2 && shift 2;;
       -skip_ssh) skip_ssh=1 && shift ;;
       -skip_jdk) skip_jdk=1 && shift ;;
    esac
done

if [ "$hostname" = "" ]
  then
    echo "-hostname is required!"
    exit 1
fi

if [ $skip_ssh -eq 0 ] && [ $skip_jdk -eq 0 ] && [ "$yum_baseurl" = "" ]
  then
    echo "-yum_baseurl is required!"
    exit 1
fi

/usr/sbin/ntpdate -u 202.108.6.95
service ntpd start

### set hostname

hostname $hostname
sed -i "s/HOSTNAME=.*/HOSTNAME=${hostname}/g" /etc/sysconfig/network


### set the limits
res=`grep '*          hard    nproc     unlimited' /etc/security/limits.d/90-nproc.conf`
if [ "$res" = "" ]
   then 
      echo "*          hard    nproc     unlimited" >> /etc/security/limits.d/90-nproc.conf
fi

res=`grep '*          soft    nproc     unlimited' /etc/security/limits.d/90-nproc.conf`
if [ "$res" = "" ]
   then 
      echo "*          soft    nproc     unlimited" >> /etc/security/limits.d/90-nproc.conf
fi


res=`grep '* soft nofile 65535' /etc/security/limits.conf `
if [ "$res" = "" ]
   then 
      echo "* soft nofile 65535"  >>  /etc/security/limits.conf 
fi 

res=`grep '* hard nofile 65535' /etc/security/limits.conf `
if [ "$res" = "" ]
   then 
      echo "* hard nofile 65535"  >>  /etc/security/limits.conf 
fi 




##关闭THP
echo never > /sys/kernel/mm/redhat_transparent_hugepage/enabled
echo never > /sys/kernel/mm/redhat_transparent_hugepage/defrag

res=`grep "echo never > /sys/kernel/mm/redhat_transparent_hugepage/enabled" /etc/rc.local`
if [ "$res" = "" ]
   then
     echo "echo never > /sys/kernel/mm/redhat_transparent_hugepage/enabled" >> /etc/rc.local
fi


res=`grep "echo never > /sys/kernel/mm/redhat_transparent_hugepage/defrag" /etc/rc.local`
if [ "$res" = "" ]
   then
     echo "echo never > /sys/kernel/mm/redhat_transparent_hugepage/defrag" >> /etc/rc.local
fi



#关闭防火墙
service iptables stop 
chkconfig iptables off 

#关闭selinux
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

#最大限度使用物理内存
res=`grep 'vm.swappiness' /etc/sysctl.conf`
if [ "$res" = "" ]
   then
     echo "vm.swappiness=0" >> /etc/sysctl.conf
fi
swapoff -a

res=`grep 'vm.max_map_count' /etc/sysctl.conf`
if [ "$res" = "" ]
   then
     echo "vm.max_map_count=6553600" >> /etc/sysctl.conf
fi

sysctl -p

##ssh 免密码
if [ $skip_ssh -eq 0 ]
 then
    rm -rf /root/.ssh
    ssh-keygen -t rsa -P ''<< EOF
/root/.ssh/id_rsa
EOF
    pub_key=`curl "${yum_baseurl}/SG/centos6/1.0/id_rsa.pub"`

    res=`grep "$pub_key" ~/.ssh/authorized_keys`
    if [ "$res" = "" ]
      then
         echo $pub_key >>  ~/.ssh/authorized_keys
    fi
fi

yum upgrade openssl -y 

#安装jdk
if [ $skip_jdk -eq 0 ]
 then
    pushd /usr/local/
    packagename="jdk-8u91-linux-x64.tar.gz"
    wget ${yum_baseurl}/SG/centos6/1.0/${packagename}
    echo "tar -zxf ${packagename}  ..."
    tar -zxf ${packagename}
    rm -rf jdk18
    mv jdk1.8.0_91 jdk18
    rm -rf ${packagename}
    popd 
fi
