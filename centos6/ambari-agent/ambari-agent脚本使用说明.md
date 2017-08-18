# ambari-agent脚本使用说明 #

## 1. 准备 ##
### hosts文件
hosts文件用于写入需要添加的agent的主机名, root用户的密码，该主机的IP地址
按行写入，每行代表一个主机(ambari-agent)，各项目之间以空格“ ”分割
例：
```
test3.sugo.vm 123456789 192.168.0.110
```

## 2. 脚本使用 ##
### pre_add_agent.sh
此脚本用于安装agent之前的主机准备，包括安装jdk、配置ambari-server到该agent的ssh免密码登录、系统优化等，且jdk、ssh免密码可选择性安装
具体使用可通过如下命令进行查看
```
./pre_add_agent.sh -help
```

### add_agent.py
此脚本用于安装、注册ambari-agent，会在hosts文件中列出的主机上安装注册agent，运行此脚本需输入参数：集群名称 ambari-server的IP地址
例：
```
python add_agent.py testCluster 192.168.0.110 hosts
```
注：此脚本包含安装和注册两个部分，由于主机的配置等因素不同，安装所需时间也会不同，而注册需要安装完成后才可执行，此处设置安装等待时间为5秒，若因配置原因，脚本注册部分执行失败，重复执行该脚本即可