# 集群部署文档（待续） #

## 1 前期准备 ##
1.1 主机配置要求  
建议机器最低配置（也可根据实际情况降低配置，但不建议这样做）  
Cpu ：8核， 内存：32g   数量：3  
系统要求： centos6.8（其他版本没测试过）  
不能连接外网的，请搭好局域网centos yum源。  
机器数量较多时，建议搭建内部dns服务器  
  
1.2 组件安装规划  
各组件在各主机上的分布如下：

Services| Components|test01.sugo.vm|test02.sugo.vm|test03.sugo.vm
-------|----------|----------|----------|----------
Ambari Metrics  |   Metrics Collector   |   安 | |
Ambari Metrics  |   Grafana | 安 |  |
Ambari Metrics  |   Metrics Monitor | 安 | 安 | 安　	　	　
PostgresQL  |   Postgres server     |安	　	　	　
Redis	|Redis server   | 安	　	　	　
Zookeeper	|ZooKeeper  Server  |安|安|安	　	　	　
HDFS	|Namenode   |安|安	　	　	　
HDFS	|Datanode   |安|安|安	　	　	　
HDFS	|ZKFailoverController   |安|安|	　	　	　
HDFS    |Journalnode    |安|安|安	　	　	　
Yarn    |Resourcemanager    |安|安	　	　	　
Yarn	|ProxyServer    |安	　	　	　
Yarn	|Nodemanager    |安	　	　	　
MapReduce	|History Server |   安	　	　	　
Kafka	|Kafka Broker   |||安	　	　	　
Druid	|Broker |安|安	　	　	　
Druid	|Historical ||安|安　	　	　
Druid	|Overlord   |安|安	　	　	　
Druid	|MiddleManager  |安|安　	　	　
Druid	|Coordinator    |安|安　	　	　
Astro	|ASTRO UI   |安	　	　
OpenResty	|OpenResty Server   |安	　	　	　




## 2 ambari-server安装 ##
做好主机规划并准备主机，配置静态IP，修改主机hostname，安装相关软件包，如果是离线主机，需要配置本地安装源库，规划数据存储目录

注：  
hostname需设为二级域名，如test01.sugo.vm  
需要安装的相关软件包：wget、ntp、openssh-clients  
ambari-server主机的/etc/hosts文件，需添加集群各主机IP与hostname的映射  
另需在/etc/目录下新建ip.txt文件，并添加ambari-server主机外所有主机的hostname+root密码  
创建sugo_yum源存放目录，上传sugo_yum源 
在根目录下创建或上传启动脚本  
启动启动脚本进行安装

```
vi /etc/hosts  
	192.168.10.1 test01.sugo.vm
		...
vi /etc/ip.txt
	test02.sugo.vm 123456
	test03.sugo.vm 123456  
		...
mkdir /data
cd
vi pre_servers.sh
vi sugo_yum_inst.sh
chmod 750 pre_servers.sh sugo_yum_inst.sh
./pre_servers.sh $httppost $sugo_yum_dir $datadir
```

$httppost为http服务需要修改为的端口号  
$sugo_yum_dir为sugo_yum源的路径  
$datadir为数据存放路径  
例：
```
./pre_servers.sh 81 /data /data
```

如果没有报错信息，则表明ambari-server安装成功， web UI默认端口8080，后面的应用主要通过界面安装
 

Ambari Metrics安装
参数：Grafana Admin Password：admin admin

## 3 服务安装 ##
### 3.1  Postgresql安装  ###
添加服务  
勾选想要安装的组件，点击下一步  
分配该服务安装在哪些节点上  
完成配置文件(安装PostgreSQL需要修改端口号，其它组件一般不需要修改)  
postgres.password: 123456 123456  
port: 15432  
检查配置信息、部署  
安装启动和测试，等待安装完成  
安装完成

### 3.2  Redis安装 ###

### 3.3  Zookeeper安装 ###
注：生产环境中至少部署三个节点

### 3.4  HDFS安装 ###
###### 3.4.1 环境要求：
保证两个目录地址NameNode.dfs.namenode.name.dir不存在
两个NameNode的hdfs用户能互相免密码登录

###### 3.4.2 可修改参数：
dfs.namenode.name.dir  
dfs.namenode.data.dir  
hadoop.log.dir  
dfs.journalnode.edits.dir  
hadoop.tmp.dir  

###### 3.4.3 安装：
此处的HDFS为HA模式，有两个NameNode，假设NN1为Active Namenode，NN2为Standby Namenode。
 
正常情况下会报错ZKFailoverController(zkfc)启动失败，不报错表示已经安装过HDFS，跳过失败，点击下一步，按照以下顺序操作：
1) 在NN1节点执行：
su - hdfs -c "hdfs zkfc -formatZK -nonInteractive"
 
2) 启动所有zkfc
 
重新启动2个ZKFailoverController
3) 在NN1节点执行格式化：
su - hdfs -c "hdfs namenode -format"
4) 启动NN1
 
5) 在NN2节点执行格式化后的数据同步：
su - hdfs -c "hdfs namenode -bootstrapStandby"
6) 启动NN2(与启动NN1相同)
7) 重启所有DataNode

### 3.5  Yarn安装
可修改参数：  
YARN Log Dir Prefix  
yarn.nodemanager.log-dirs  
yarn.nodemanager.local-dirs  

hdfs目录创建：  
此处假设yarn.nodemanager.remote-app-log-dir为默认hdfs目录/remote-app-log/logs:  
```
su - hdfs  
hdfs dfs -mkdir -p /remote-app-log/logs
hdfs dfs -chown -R yarn:hadoop  /remote-app-log
hdfs dfs -chmod 777 /remote-app-log/logs
```

### 3.6  MapReduce安装
可修改参数：  
MapRduce Log Dir Prefix  
yarn.app.mapreduce.am.staging-dir  

hdfs目录创建： 

```
hdfs dfs -mkdir -p /mr_history/tmp  
hdfs dfs -chmod 777 /mr_history/tmp  
hdfs dfs -mkdir -p /mr_history/done  
hdfs dfs -chmod 777 /mr_history/done  
hdfs dfs -mkdir -p /tmp/hadoop-yarn/staging  
hdfs dfs -chmod 777 /tmp/hadoop-yarn/staging  
```

### 3.7  Druidio安装
环境要求：  
Postgresql(可通过界面安装)  
创建druid库(UTF8，Postgres)（2.6.1和2.6.2选一种方法即可）  

###### 3.7.1 界面建库：  
下载、安装Postgresql界面管理工具Navicat for PostgreSQL，连接数据库，创建druid库
   
如果连接时显示密码错误，则进入postgres用户，进行参数设置  
```
/opt/apps/postgres_sugo/bin/psql -d postgres -U postgres -p 15432 -c "ALTER USER postgres PASSWORD '123456';"
```  

###### 3.7.2 CLI命令建库：

```
cd /opt/apps
bin/psql -p 15432 -U postgres -d postgres -c "CREATE DATABASE druid WITH OWNER = postgres ENCODING = UTF8;"
bin/psql -p 15432 -U postgres -d postgres -c "select datname from pg_database"
bin/psql -p 15432 -U postgres -d postgres -c "CREATE DATABASE sugo_astro WITH OWNER = postgres ENCODING = UTF8;"
bin/psql -p 15432 -U postgres -d postgres -c "select datname from pg_database"
```

建议修改参数：  

```druid.metadata.storage.connector
druid.license.signature: 
druid.metadata.storage.connector.connectURI: jdbc:postgresql://test01.sugo.vm:15432/druid
druid.metadata.storage.connector.password: 123456 123456
```

自定义参数：  

```
supervisor.kafka.zkHost:
```
如果已准备Zookeeper，则此配置需要加上，host:端口号192.168.1.122:2181,192.168.1.126:2181,192.168.1.240:2181(例)  
此步骤注意参数的修改！

hdfs目录创建：  
```
hdfs dfs -mkdir -p /druid/hadoop-tmp
hdfs dfs -mkdir -p /druid/indexing-logs
hdfs dfs -mkdir -p /druid/segments
hdfs dfs -chown -R druid:druid /druid
hdfs dfs -mkdir -p /user/druid
hdfs dfs -chown -R druid:druid /user/druid
```

### 3.8  Kafka安装
可修改参数：
log.dirs

### 3.9  Astro安装
环境要求：  
Postgresql(可通过界面安装)，并创建sugo_astro库(UTF8，Postgresl)：  
redis(可通过界面安装)

下载、解压缩user-group-1.0.tgz并启动  
```
wget -P /opt/apps/ http://192.168.10.142/sugo_yum/SG/centos6/1.0/user-group-1.0.tgz
tar -zxvf user-group-1.0.tgz
cd user-group-1.0
./start.sh  
```
查看端口情况：
```
netstat -nap | grep 2626
``` 

建议修改参数（视频上安装user_group可以不安装）：  
```
postgres.host: test01.sugo.vm
dataConfig.hostAndPorts: test01.sugo.vm:6379
db.host: test01.sugo.vm
db.port: 15432
db.password: 123456 123456
redis.host: test01.sugo.vm
site.sdk_ws_url: ws://test01.sugo.vm:8887
site.websdk_api_host: test01.sugo.vm
site.websdk_decide_host: test01.sugo.vm:8000
site.collectGateway: http://test01.sugo.vm
```

### 3.10 安装Openresty
环境要求：  
redis(可通过界面安装)  
注意：如果前面httpd服务的端口号没有修改，则会与nginx的端口产生冲突  
可修改参数：
```
log.bakcup.dir:  
nginx.working_directory:  
redis_host:  
```
自定义参数（此参数在使用非sugo提供的kafka时添加，使用sugo安装kafka时不需要添加）：  
kafka.brokers: 192.168.1.122:59092,192.168.1.126:59092,192.168.1.240:59092（例）

### 4 验证安装是否成功
至此，服务安装完成，查看Web界面、导入数据验证安装成功，具体可查看视频  
查看的服务：  
HDFS（包括activeNamenode，standbyNamenode）  
DruidIO  
Astro（admin:admin123456,创建项目、导入数据、采集数据）