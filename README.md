![](media/11d9e2fcdd89e39d53acf7b9b90d4a36.jpg)

# 目录 #




[1. 项目介绍   3](#_Toc487116557)

[2. 技术架构   3](#_Toc487116558)

[3. 集群部署架构   4](#_Toc487116559)

[4. 单机版部署   7](#_Toc487116560)

&emsp;[4.1 前期准备   8](#_Toc487116561)

&emsp;[4.2 一键部署   8](#_Toc487116562)

&emsp;[4.3 环境测试   9](#_Toc487116563)

[5. 分布式集群部署   9](#_Toc487116564)

&emsp;[5.1 前期准备   9](#_Toc487116565)

&emsp;&emsp;[5.1.1主机配置要求   9](#_Toc487116566)

&emsp;&emsp;[5.1.2 组件安装规划及准备   10](#_Toc487116567)

&emsp;[5.2安装Ambari-Server   11](#_Toc487116568)

&emsp;[5.3集群部署 13](#_Toc487116569)

&emsp;&emsp;[5.3.1 一键部署 20](#_Toc487116570)

&emsp;&emsp;[5.3.2 独立部署 39](#_Toc487116571)

&emsp;[5.4 分布式集群测试 52](#_Toc487116572)

[6 集群管理 58](#_Toc487116573)

&emsp;[6.1 启动集群 58](#_Toc487116574)

&emsp;[6.2 更新服务 59](#_Toc487116575)

&emsp;[6.3 增删Ambari-Agent 63](#_Toc487116576)

&emsp;&emsp;[6.3.1 增加Agent 64](#_Toc487116577)

&emsp;&emsp;[6.3.2 迁移服务 65](#_Toc487116578)



# 1. 项目介绍 #


&emsp;&emsp;数果Tindex平台是数果智能自主研发的产品，用于解决大数据行业中实现大规模（PB级）行为数据实时接入、高效存储和快速查询，满足数据分析和数据挖掘等领域的需求。

# 2. 技术架构 #

&emsp;&emsp;数果Tindex平台核心组件包含Broker, Coordinator, MiddleManager, Overlord,Historical，整体架构如如图1所示：

<h6 style="text-align:center">![](media/a490c303198379f78bb8fe6aa031250f.png)</h6>

<center>图1 Tindex技术架构图</font></center>

<h6 style="text-align:center">图1 Tindex技术架构图</h6>

-   Broker节点：接受客户端请求，分发至各历史/实时节点，然后汇总返回客户端的节点

-   Coordinator节点：用于在平衡各历史节点负载的节点。

-   Overlord节点：用于调度实时/离线数据接入任务的节点。

-   MiddleManager节点：用于启动实时/离线数据接入任务的节点。

-   Historical节点：用于加载并提供历史数据查询功能的节点。

# 3. 集群部署架构 #

&emsp;&emsp;分布式集群借助Ambari进行部署，并利用Amabri对集群进行统一管理和监控，技术架构中的所有组件均通过Ambari进行部署、监控和管理，这里以3节点为例，介绍分布式集群的部署架构。

&emsp;&emsp;数果智能将Ambari汉化及添加自研组件后，改名为Alaska，整体框架基本不变，所以Alaska在此文档中仍称为Amabri，Ambari基本架构如图2所示

![](media/b03c38e3c7b6576598a88f7a7070a03c.png)

###### 图2 Ambari架构图 ######

&emsp;&emsp;Apache Ambari是一种基于Web的工具，支持Apache Hadoop集群的供应、管理和监控。Ambari目前已支持大多数Hadoop组件，包括HDFS、MapReduce、Hive、Pig、Hbase、Zookeper、Sqoop和Hcatalog等。

&emsp;&emsp;Ambari主要包括Ambari Server和Amabri Agent两部分，Ambari Server在整个架构中只有一个，元数据信息存储在Postgres数据库中，通过心跳信息的传递对多个Ambari Agent进行管理，Ambari Agent与主机一一对应，Ambari通过Ambari Agent对该主机上的组件进行管理。

如图3所示为基于Ambari的部署架构：

![](media/5828887ca24ea89f27f69e257c61ffc7.png)

###### 图3 Ambari的部署架构 ######

&emsp;&emsp;3台主机对应3个Ambari Agent，其中一台主机安装Ambari Server，每台主机上安装、运行的进程如图，每台主机安装多个组件，节点上安装的进程由该节点主机性能等因素决定，可灵活调整。主机部署规划可咨询数果智能。组件之间具有依赖关系，所以组件的安装需基于上图的顺序（从下往上）进行安装配置。

具体安装流程如下：

>   1）安装Ambari-Server，注册主机

>   2）部署集群

>   3）修改配置、启动组件

>   4）集群测试

部署集群有两种方式供选择，一键部署和独立部署。

&emsp;&emsp;1）一键部署：主要在终端操作，修改安装所需的配置文件后，运行安装脚本；

&emsp;&emsp;2）独立部署：主要是通过Ambari的Web界面进行操作。

&emsp;&emsp;一键部署适合对Linux系统熟悉，对Json语法规则有所了解的人员。独立部署操作界面更友好，但耗时一些。建议非运维人员通过独立部署方式进行安装，具体操作在分布式集群部署部分有详细介绍，可先查看再决定部署方式。

# 4. 单机版部署 #

&emsp;&emsp;本部分描述的单机版部署，所有服务均安装在同一台主机上，是在全新安装的主机上进行的，不建议在已有其它服务的主机上进行部署。由于部分环境内网无法访问，需要通过公网进行访问，则需要绑定公网IP，并且在启动部署脚本时会有些不同。

## 4.1 前期准备 ##

##### 主机配置要求 #####

| **项目** | **要求** | **备注**                 |
|----------|----------|--------------------------|
| CPU      | 4核以上  |                          |
| 总内存   | 16G以上  |                          |
| 磁盘     |          | 根据数据量、存储周期决定 |

**表1 单机版主机配置要求**

&emsp;&emsp;也可根据实际情况对主机配置进行调整，但不建议降低配置，主机安装系统(建议CentOS6.8)后，修改静态IP地址，下载单机版安装包，如果无法连接网络，请安装本地yum源。

## 4.2 一键部署 ##

&emsp;&emsp;解压单机版安装包，启动安装脚本，如果内网无法访问，需要通过公网IP对服务进行访问时，请绑定公网IP，且启动安装脚本时，参数选择会略有不同。
```
tar –zxvf single_deploy.tar.gz
cd single_deploy
1)无需公网IP时执行：
source single-deploy.sh –IP 192.168.0.120
2)需要公网IP时执行：
source single-deploy.sh –IP 192.168.0.120 -public_IP 192.168.0.121
```

&emsp;&emsp;此时，所有服务安装完成并启动，如果需要公网IP才能访问，请开放端口80、8000、8887和8090，如果不需要公网IP，可以直接访问，则无需设置端口转发。

&emsp;&emsp;如果安装是通过无需公网IP的方式执行部署脚本，而安装完成后因其它原因需要通过公网IP才能访问时，请开放端口，且将以下参数的IP地址修改为公网IP：

```
cd /opt/apps/astro_sugo/analytics
vim config.js
collectGateway: 'http://192.168.0.122',
sdk_ws_url: 'ws://192.168.0.122:8887',
websdk_api_host: '192.168.0.122:8000'

```


## 4.3 环境测试 ##

&emsp;&emsp;测试方法与分布式集群测试一致，具体请参考分布式集群测试步骤。



# 5. 分布式集群部署 #

## 5.1 前期准备 ##

### 5.1.1 主机配置要求 ###

| **项目** | **要求** | **备注**                 |
|----------|----------|--------------------------|
| 总CPU    | 8核以上  |                          |
| 总内存   | 32G以上  |                          |
| 主机数量 | 3台以上  |                          |
| 磁盘     |          | 根据数据量、存储周期决定 |

**表2 主机配置要求**

&emsp;&emsp;也可根据实际情况对主机配置进行调整，但不建议降低配置

### 5.1.2 组件安装规划及准备 ###

&emsp;&emsp;根据技术架构、部署架构及主机配置，合理规划组件的安装节点，表3为3节点的安装规划（3台主机配置均为4核16G），供参考，具体可咨询数果智能。

| **Services**   | **Components**       | **Host1** | **Host2** | **Host3** |
|----------------|----------------------|-----------|-----------|-----------|
| Ambari Metrics | Metrics Collector    | √         |           |           |
|                | Grafana              | √         |           |           |
|                | Metrics Monitor      | √         | √         | √         |
| PostgresQL     | Postgres server      | √         |           |           |
| Redis          | Redis server         | √         |           |           |
| Zookeeper      | ZooKeeper Server     | √         | √         | √         |
| HDFS           | Namenode             | √         | √         |           |
|                | Datanode             | √         | √         | √         |
|                | ZKFailoverController | √         | √         |           |
|                | Journalnode          | √         | √         | √         |
| Yarn           | Resourcemanager      | √         | √         |           |
|                | ProxyServer          | √         |           |           |
|                | Nodemanager          | √         |           |           |
| MapReduce      | History Server       | √         |           |           |
| Kafka          | Kafka Broker         |           |           | √         |
| Tindex         | Broker               | √         | √         |           |
|                | Historical           |           | √         | √         |
|                | Overlord             | √         | √         |           |
|                | MiddleManager        | √         | √         |           |
|                | Coordinator          | √         | √         |           |
| Astro          | ASTRO UI             | √         |           |           |
| Gateway        | Gateway Server       | √         |           |           |

**表3 安装配置要求**

&emsp;&emsp;做好主机规划后，配置好各主机的静态IP，修改hostname，注意hostname需要为二级域名，如：test1.sugo.vm，如果是离线主机，需要配置本地yum安装源库。这部分的具体操作不做描述。


## 5.2 安装Ambari-Server ##

安装Ambari-Server的不同场景：

-   如果您的主机是新安装的，在配置静态IP、修改hostname后，可通过脚本一键安装Ambari-Server，这也是我们推荐的方式；

-   如果您的主机上有其它服务（部署架构中不包含该服务），请手动安装，或通过查看脚本start.sh使用参数，选择性执行脚本，或对其修改来进行安装；

-   如果需要将集群与已有的组件集成，请联系数果人员，由数果人员安装；

生产环境请与数果人员沟通或由数果人员进行安装，勿利用此脚本独自安装！

以下步骤是在新安装系统的主机上部署的过程：

-   创建数据存储目录，下载本地安装的yum源安装包（联系数果智能获取下载链接）；

-   解压安装包，进入部署脚本目录\${yum源下载目录}/sugo_yum/deploy_scripts/centos6/ambari-server/，修改host和ip.txt文件。host文件为各主机ip与hostname的映射，ip.txt文件为ambari-server所在主机外，其它所有主机的hostname+root用户密码，以空格分割；

-   修改完成后保存，执行脚本start.sh（http的端口号建议设置为81，因为安装网关时会占用端口号80），具体操作如下：

```
mkdir ${数据存储目录}
cd ${数据存储目录}
wget ${yum源下载链接}
tar –zxvf ${yum源下载目录}/sugo_yum.tar.gz
cd ${yum源下载目录}/sugo_yum/deploy_scripts/centos6/ambari-server/

vi host
192.168.10.1 test1.sugo.vm
192.168.10.2 test2.sugo.vm
192.168.10.3 test3.sugo.vm

vi ip.txt
test2.sugo.vm 123456
test3.sugo.vm 123456
```

```
./start.sh -http_port 端口号 –ambari_ip Ambari-Server节点IP

例：

./start.sh -http_port 81 –ambari_ip 192.168.10.1
```

&emsp;&emsp;如果没有报错信息，则表明ambari-server安装成功。登陆界面如图4所示， web UI默认端口8080(admin,admin)，组件的安装可通过一键部署或独立部署实现。

![](media/117abb489766863acbc8e9bcb01a1028.png)

**图4 ambari-server登陆界面**

## 5.3 集群部署 ##

&emsp;&emsp;主机注册及Ambari Metrics安装，通过Web界面登录后会提示注册集群、主机，ssh秘钥及安装Ambari Metrics，具体操作如下：

#### 第1步：启动安装向导（如图5所示）；

![](media/c59d3a24ff914b5d3a2f94a9f0bc9417.png)

**图5 Ambari安装向导页面**

#### 第2步：创建集群 ####
&emsp;&emsp;命名集群，选择服务栈（此处仅勾选redhat6），浏览器打开http服务地址（如图6所示），选择1.0所在的目录，复制链接粘贴到Ambari界面的”基础URL”内（如图7所示）。

![](media/45009e03fd13af2bc78deca47a16802a.png)

**图6 基础URL链接**

![](media/a793662acf52ccbbdfb6d736cc1a07e1.png)

**图7 选择服务栈**

#### 第3步：填写秘钥 ####
&emsp;&emsp;点击下一步后，如图8所示，获取秘钥（在Ambari-server所在节点的终端查询），复制粘贴到安装选项界面（如图9所示），同时在界面填写目标主机：

```
cat ~/.ssh/id_rsa
```

![](media/7e5d8b40a9360ce897e919dbe9b426e7.png)

###### 图8 SSH秘钥 ######

![](media/8ab31938375d320ef5352cfcd7af1845.png)

**图9 安装选项界面**

#### 第4步：注册 ####
&emsp;&emsp;确认注册，Ambari-Server便开始注册主机并检测环境，图10表明主机注册成功，点击下一步，勾选Ambari Metrics，点击下一步，分配主从节点，可打开下拉框选择将Ambari Metrics安装在您规划的主机上，一般默认即可，按照提示填写参数Grafana Admin Password（admin,admin。也可自行填写其它密码），下一步，部署，然后等待安装完成。

![](media/ce2c73b9dc770e46da01a775db45f7d9.png)

![](media/f8a9b0f5341349c109b517f3bff56c69.png)

![](media/991867d2f9acf91c6ef8c427f5ccc901.png)

**图10 主机注册及Ambari Metrics安装成功界面**

### 5.3.1 一键部署 ###

#### 1）部署服务 ####

&emsp;&emsp;首先，打开终端，进入部署脚本目录，按照部署架构或组件规划修改配置文件host_server.json（建议在其它编辑器上编辑，如notepad++，完成后复制到该文件内），修改install.py脚本，修改Ambari-Server节点的IP和界面注册时填写的集群名称，如图11所示。

![](media/4f95dbab1c070af3ee40d0d6d84c5204.png)

![](media/1f3b1f1c81b38c212acaafa658488f61.png)

**图11 修改配置设置**

&emsp;&emsp;接着，启动一键部署脚本，等待脚本执行完成，如图12所示，完成后打开Web界面：

```
python install.py
```

![](media/2598a330d6bdc1fc447009013e669766.png)

**图12 正在安装服务界面**

&emsp;&emsp;图12 显示正在安装相关组件，等待安装完成，完成后如图13所示，即可开始修改配置。

![](media/2db3e7fa7a6a59a2cc519979696b302c.png)

**图13 成功安装服务界面**

#### 2）修改配置，启动服务 ####

&emsp;&emsp;表4为需要修改的服务和参数：

| **Services** | **Parameters**                              | **Value(example)**                          | **备注**                                  |
|--------------|---------------------------------------------|---------------------------------------------|-------------------------------------------|
| Postgres     | postgres.password                           | 123456                                      | Postgres数据库密码                        |
|              | port                                        | 15432                                       | Postgres数据库端口号                      |
| Gateway      | bootstrap.servers                           | test1.sugo.vm:9092                          | Kafka主机名:9092，多个kafka之间以逗号分割 |
| Druid        | druid.license.signature                     |                                             | 联系数果智能获取秘钥                      |
|              | druid.metadata.storage.connector.connectURI | jdbc:postgresql://test1.sugo.vm:15432/druid | 连接到Postgres的druid库地址               |
|              | druid.metadata.storage.connector.password   | 123456                                      | Postgres数据库密码                        |
| Astro        | postgres.host                               | test1.sugo.vm                               | Postgres数据库主机名                      |
|              | dataConfig.hostAndPorts                     | test1.sugo.vm:6379                          | Redis数据库主机及端口号                   |
|              | db.host                                     | test1.sugo.vm                               | Postgres数据库主机名                      |
|              | db.port                                     | 15432                                       | Postgres数据库端口号                      |
|              | db.password                                 | 123456 123456                               | Postgres数据库密码                        |
|              | redis.host                                  | test1.sugo.vm                               | Redis数据库主机                           |
|              | site.collectGateway                         | http://test1.sugo.vm                        | 数据上报网关                              |
|              | site.sdk_ws_url                             | ws://test1.sugo.vm:8887                     | App可视化埋点socket链接                   |
|              | site.websdk_api_host                        | test1.sugo.vm                               | Web数据上报网关                           |
|              | site.websdk_decide_host                     | test1.sugo.vm:8000                          | Web获取埋点事件服务端                     |
|              | site.websdk_app_host                        | test1.sugo.vm:8000                          | Web获取埋点事件服务端                     |
|              |    site.websdk_js_cdn                       | test1.sugo.vm:8000                          | Web埋点埋点js服务cdn                      |

**表4 修改的服务和参数**

##### a. 修改Postgres参数 #####

如图14 所示，
修改Postgres的参数，具体[参数](#参数表)如表3所示，修改完成后保存，启动Postgres。

![](media/2f6a68ab9e4c8090697b750ee68f6771.png)

**图14 修改Postgres参数**

正常启动后，创建其它服务的依赖库（如图15所示）：

```
cd /opt/apps/postgres_sugo
bin/psql -p 15432 -U postgres -d postgres -c "CREATE DATABASE druid WITH OWNER = postgres ENCODING = UTF8;"
bin/psql -p 15432 -U postgres -d postgres -c "CREATE DATABASE sugo_astro WITH OWNER = postgres ENCODING = UTF8;"
bin/psql -p 15432 -U postgres -d postgres -c "select datname from pg_database"
```


![](media/a6b3757d18d92691fbeebdcd60997a95.png)

**图15 创建依赖库窗口**

##### b. Redis、Zookeeper #####

直接点击启动按钮即可。

##### c. HDFS #####

第1步：点击启动所有，启动完成后HDFS会出现如下报错信息（如图16所示），属正常现象。

![](media/9715b0acab30ccf36a40af96121dc38f.png)

**图16 报错提示**

第2步：在NameNode1节点上执行zkfc格式化（如图17所示）：

```
su - hdfs -c "hdfs zkfc -formatZK -nonInteractive"
```

![](media/8f5766192ec71b1c1ab0f0bb21ee3402.png)

**图17 zkfc格式化**

第3步：格式化完成后，在界面启动所有zkfc（如图18所示）。

![](media/91182aae1f61afa649a9e5ccca344324.png)

**图18 ZKFC启动界面**

![](media/10ccc7f1151ea9a77a5b7e1d337883cf.png)

**图19 ZKFC重启界面**

第4步：zkfc重启完成后，界面会显示zkfc处于启动状态，然后在NameNode1上执行格式化操作：

```
su - hdfs -c "hdfs namenode -format"
```

![](media/9ea3bb5eaa8e53d53b8d4ce90e9fa399.png)

**图20 NameNode1执行格式化**

第5步：格式化完成后，在界面重启NameNode1（如图21）。

![](media/75c3336b027bdcd6eaefc70ddccf80d1.png)

![](media/7c4c6148749aab126d81a7dcef3c0b43.png)

**图21重启 NameNode1**

第6步：启动完成后，如图22所示，界面会显示test1.sugo.vm上的NameNode已启动。

![](media/28b268d9cb75a766f990d42649f22023.png)

**图22 成功启动NameNode1**

第7步：在NameNode2节点执行格式化后的数据同步（如图22所示）。

```
su - hdfs -c "hdfs namenode -bootstrapStandby"
```

![](media/8c3b3b4a62ca24927d27cd3683b0a248.png)

**图23 NameNode2执行格式化后的数据同步**

第8步：数据同步命令执行完成后，启动NameNode2

![](media/bf35f709aa97a0f420a1ea62e1a88115.png)

**图24重启 NameNode**2

启动完成后不再显示报错信息

![](media/5d4337a17029dc0d60ebc19a7c46d945.png)

**图25 HDFS安装启动成功**

第9步：创建其它服务依赖的文件目录，在HDFS Client节点的终端执行如下命令：

```
su - hdfs
hdfs dfs -mkdir -p /remote-app-log/logs
hdfs dfs -chown -R yarn:hadoop /remote-app-log
hdfs dfs -chmod 777 /remote-app-log/logs

hdfs dfs -mkdir -p /mr_history/tmp
hdfs dfs -mkdir -p /mr_history/done
hdfs dfs -chmod 777 /mr_history/
hdfs dfs -mkdir -p /tmp/hadoop-yarn/staging
hdfs dfs -chmod 777 /tmp/hadoop-yarn/staging

hdfs dfs -mkdir -p /druid/hadoop-tmp
hdfs dfs -mkdir -p /druid/indexing-logs
hdfs dfs -mkdir -p /druid/segments
hdfs dfs -chown -R druid:druid /druid
hdfs dfs -mkdir -p /user/druid
hdfs dfs -chown -R druid:druid /user/druid
```


![](media/ea41d1a22657ab4fb440ff348586760f.png)

**图26 HDFS上创建相关目录**

第10步：在浏览器上打开NameNode的IP:50070页面，通过Amabari主机名打开页面时，需要在windows的host文件中配置IP与hostname的映射

```
打开文件C:\Windows\System32\drivers\etc\host
复制Linux下/etc/hosts文件内的映射，追加到Windows的host文件末尾

192.168.10.1 test1.sugo.vm
192.168.10.2 test2.sugo.vm
192.168.10.3 test3.sugo.vm
```

![](media/c83a5689f8d162aab3e79fa06cf7cf56.png)

**图27 打开HDFS文件目录界面**

通过主机名打开HDFS界面：test1.sugo.vm:50070，查看Utilities，显示文件创建成功

![](media/73283f31f013e5df95b13e36622d0240.png)

**图28 HDFS文件目录**

第11步：配置NameNode1和NameNode2在
hdfs用户下的免密码登录，启动配置脚本（注：passwd为root用户密码）：

```
cd {脚本存储目录}/sugo_yum/deploy_scripts/service
./password-less-ssh-hdfs.sh \$namenode1 \$passwd(NN1) \$namenode2 \$passwd(NN2)

例：
./password-less-ssh-hdfs.sh test1.sugo.vm 00000001 test2.sugo.vm 00000002
```


执行完成后检查hdfs用户免密码登录是否成功，在NameNode1或NameNode2上执行以下命令：

```
su – hdfs ssh \$NameNode1 ssh \$NameNode2
```


在此例中，命令为：

```
su – hdfs ssh test1.sugo.vm ssh test2.sugo.vm
```


如果能够成功的切换到两个NameNode的hdfs用户，则说明配置成功

##### d. Kafka、YARN、MapReduce #####

直接按顺序启动即可

##### e. Gateway #####

根据[参数表](#参数表)修改参数，保存后启动即可

![](media/c315ebb351339282982c139475363f80.png)

**图29 修改Gateway参数**

##### f. Tindex #####

根据[参数表](#参数表)修改参数，保存后启动即可

![](media/0e729c9e121e16a0a8783b4887a0ce57.png)

**图30 Tindex启动成功**

##### g. Astro #####

根据[参数表](#参数表)修改参数，保存后启动即可

![](media/a1665d7612081077558f8f6cb347521c.png)

**图31 Astro启动成功**

### 5.3.2 独立部署 ###

独立部署在安装各个服务（如HDFS、YARN，图32所示左侧部分均称为服务）时，需要按照一定的顺序进行安装！

##### a. Postgres #####

第1步：添加服务（如图33所示），选择服务，勾选Postgres-sugo，点击下一步

![](media/3b6fba0b2c920fec268043d3ed1ad26b.png)

**图32 添加服务**

第2步：分配主从节点，选择Postgres安装的节点（如图34所示），点击下一步

![](media/3f58e20f314eb379e164e051441729ac.png)

**图33 分配主节点**

##### b. Redis #####

安装步骤与Postgresql基本相同，且无需修改配置信息，按照提示操作即可

##### c. Zookeeper #####

添加服务，选择服务，分配主节点，此处有多个Zookeeper
Server时，需要点击加号按钮选择多个节点安装同一个组件（此处组件为Ambari内的component）

![](media/80e67a2ca5140a50a6fe67ac62b6c9d8.png)

**图34 添加Zookeeper主节点**

按照提示完成Zookeeper的安装，配置文件无需修改

##### d. HDFS #####

第1步：按提示进行操作，分配主节点时，需要通过加号按钮添加一个NameNode（如图35所示），实现HDFS集群的高可用

![](media/d7dc4d5a886df4259a37edf040ad694a.png)

**图35 添加NameNode主节点**

第2步：点击下一步，分配从节点和客户端（如图36所示），前面的Postgresql/Redis/Zookeeper都只有主节点，HDFS既有主节点又有从节点，还有些服务只有从节点，点击下一步，部署

![](media/3b057bde8801e957e151adc199b260f0.png)

**图36 选择从节点和客户端**

注意：在安装完成后会出现报错信息（如图37所示），为正常现象，点击下一步，完成

![](media/705ccaf6befd335d4b923ab1544e4cde.png)

**图37 独立部署HDFS报错信息**

解决办法与一键部署时的启动HDFS过程完全相同，请参考一键部署的启动HDFS部分

##### e. YARN #####

按照提示操作即可，注意ResourceManager需要两个（如图38所示），实现YARN的高可用

![](media/8737607306b946bbc3a3b095903f74e5.png)

![](media/9d27850429208506f4190e4e5aaf72aa.png)

**图38 分配YARN主节点、从节点和客户端**

##### f. MapReduce #####

按照提示操作即可

##### g. Kafka #####

按照提示操作即可

![](media/3f48833c5a93a28099a76148c5dbc04c.png)

**图39 选择Kafka从节点和客户端**

##### h. Gateway #####

第1步：Gateway的安装与前两个服务略微有些不同，但是基本没有差异，服务的安装包括三种情况：主节点分配、从节点和客户端分配、两者都有

修改配置文件参数（如表5，注：如果没有该参数，则无需修改参数，安装包版本更新后，在ambari管理界面没有该参数）

| **配置项（参数）** | **参数值**         | **备注**                                  |
|--------------------|--------------------|-------------------------------------------|
| bootstrap.servers  | test1.sugo.vm:9092 | Kafka主机名:9092，多个kafka之间以逗号分割 |

**表5 Gateway需修改的参数**

第2步：安装完依赖后，在界面启动Gateway

##### i. Tindex #####

第1步：创建Postgres数据库druid（注：在Postgres所在节点执行，参数-p指定Postgres的端口号，如图40所示）:

```
cd /opt/apps/postgres_sugo
bin/psql -p 15432 -U postgres -d postgres -c "CREATE DATABASE druid WITH OWNER = postgres ENCODING = UTF8;"
bin/psql -p 15432 -U postgres -d postgres -c "select datname from pg_database"
```

![](media/01943f63a0a0b0d8ffc0c5c3311c3cbc.png)

**图40 在Postgres数据库中创建druid库**

第2步：按照提示进行操作（如图41所示）

![](media/95a98f096c703fc4a5b4aa6ef9d1a730.png)

**图41 选择druid从节点和客户端**

第3步：修改配置文件（需修改参数如表6所示），然后按提示完成安装

| **配置项（参数）**                          | **参数值**                                  | **备注**                             |
|---------------------------------------------|---------------------------------------------|--------------------------------------|
| druid.license.signature                     |                                             | 联系数果智能获取秘钥                 |
| druid.metadata.storage.connector.connectURI | jdbc:postgresql://test1.sugo.vm:15432/druid | Postgresql数据库的druid库            |

**表6 Tindex需修改的参数**

![](media/c789d1297461a5b32831b8f4fab05f8b.png)

**图42 修改druid参数界面**

##### j. Astro #####

第1步：创建Postgres数据库的sugo_astro库（如图43所示）:

```
cd /opt/apps/postgres_sugo
bin/psql -p 15432 -U postgres -d postgres -c "CREATE DATABASE sugo_astro WITH OWNER = postgres ENCODING = UTF8;"
bin/psql -p 15432 -U postgres -d postgres -c "select datname from pg_database"
```

![](media/3e1264b4eb37ae9416135f4f9f2934e5.png)

**图43在Postgres数据库中创建sugo_astro库**

第2步：按提示继续后面的安装，修改配置文件（需修改参数如表7所示），修改完成后按提示完成安装(最新安装包参数会有些不一样，但需要填写的参数值的规则不变)

| **配置项（参数）**      | **参数值**              | **备注**                |
|-------------------------|-------------------------|-------------------------|
| postgres.host           | test1.sugo.vm           | Postgres数据库主机名    |
| dataConfig.hostAndPorts | test1.sugo.vm:6379      | Redis数据库主机及端口号 |
| db.host                 | test1.sugo.vm           | Postgres数据库主机名    |
| db.port                 | 15432                   | Postgres数据库端口号    |
| db.password             | 123456 123456           | Postgres数据库密码      |
| redis.host              | test1.sugo.vm           | Redis数据库主机         |
| site.collectGateway     | http://test1.sugo.vm    | 数据上报网关            |
| site.sdk_ws_url         | ws://test1.sugo.vm:8887 | App可视化埋点socket链接 |
| site.websdk_api_host    | test1.sugo.vm           | Web数据上报网关         |
| site.websdk_decide_host | test1.sugo.vm:8000      | Web获取埋点事件服务端   |
| site.websdk_app_host    | test1.sugo.vm:8000      | Web获取埋点事件服务端   |
| site.websdk_js_cdn      | test1.sugo.vm:8000      | Web埋点埋点js服务cdn    |

**表7 Astro需修改的参数**

## 5.4 分布式集群测试 ##

第1步：打开前端Web界面IP:8000（如图44所示，帐号密码分别为：admin,admin123456)

![](media/a70f39f7f1dc2dc6814dafc5322e5faa.png)

**图44前端Astro登录界面**

第2步：进入数据管理，项目管理（如图45所示）

![](media/691ca04fd2c85ad285b621ce4d843c72.png)

**图45前端Astro进入项目管理操作**

第3步：新建项目，输入项目名称，提交后选择Csv文件接入，执行下一步（如图46所示）

![](media/c2938c96f4779b13284be16d5012d4cd.png)

**图46选择接入数据类型**

第4步：选择文件，进入下一步（如图50所示），输入名称，选择维度字段（全选），提交采集维度（如图49所示），开始采集，查看采集是否成功

![](media/d0ba9f714523a71bd482fa8dfdc42cda.png)

**图47配置接入参数**

![](media/b69ac237d9d2a860545cb6128275f1e8.png)

**图48配置采集维度**

第5步：点击自助分析（如图49所示），执行查询，出现总记录数且与源数据相同，证明部署成功（如图49所示）

![](media/9d0fa06dc05253610581108820e1b056.png)

**图49查询总记录数**

# 6 集群管理 #

## 6.1 启动集群 ##

启动集群时，由于各组件之间具有依赖关系，需要按照一定的顺序启动各组件，可以**按照图53所示的顺序启动各组件**:

![](media/a1230070bdbce29357e3348cad08c2b2.png)

**图50组件启动顺序参考图**

## 6.2 更新服务 ##

通过Ambari界面更新数果智能自研组件，无需重复配置参数，暂时仅适用于数果智能自研组件。

更新服务具体步骤如下:

第1步：下载更新安装包到http服务所在目录，即Ambari指向的基础URL地址（如图54所示），在Ambari界面的管理员中查看，Linux系统上的位置一般为：/var/www/html/sugo_yum/SG/centos6/1.0，操作命令如下:

```
cd /var/www/html/sugo_yum/SG/centos6/1.0
wget {安装包链接（联系数果智能获取）} service httpd start
```

![](media/dde6ceeaf9c7e7fec391028c56da6095.png)

**图51查看Ambari的基础URL地址**

**第2步：**修改安装包包名，需与该服务配置文件中的package.name保持一致，之前的安装包可修改名称作为备份；

![](media/16414230d4021e9f9dce5bda956bc3a9.png)

**图52查看该服务配置文件中的package name**

第3步：点击该服务的Client（如图56所示），选择该服务所在主机（如果该服务部署在多台主机上，每台主机都需要更新操作）

![](media/b9201a6d8dc4c6d74c3089ddac787f3f.png)

**图53选择该服务的客户端**

第4步：选择主机后，下拉页面到最底端，点击更新按钮（如图54所示），即可一键更新服务

![](media/fdfdd354a339729f0b65a6562ceb8625.png)

**图54一键更新服务操作**

## 6.3 删除服务 ##

删除服务的功能尚未集成到Ambari管理界面，暂时只能通过API的方式删除服务。

删除服务具体步骤如下:

第1步：进入到ambari-server所在主机

第2步：执行以下命令，需修改的部分：ambari-server的IP，集群名称和服务名称，各服务服务名称如下

| **服务**   | **服务名称**   |
|------------|----------------|
| PostgresQL | POSTGRES_SUGO  |
| Redis      | REDIS_SUGO     |
| Zookeeper  | ZOOKEEPER_SUGO |
| HDFS       | HDFS_SUGO      |
| YARN       | YARN_SUGO      |
| MapReduce  | MAPREDUCE_SUGO |
| kafka      | KAFA_SUGO      |
| Gateway    | GATEWAY_SUGO   |
| Tindex     | DRUIDIO_SUGO   |
| Astro      | ASTRO_SUGO     |

**表8 各服务在删除时，API命令中的服务名称**

```
curl -u admin:admin -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo":{"context":"Stop Service"},"Body":{"ServiceInfo":{"state":"INSTALLED"}}}' http://192.168.0.220:8080/api/v1/clusters/sugo_test/services/ASTRO_SUGO
```


![](media/73ac31cdcd6e07a5732bdf785a66b430.png)

**图55停止服务操作**

执行完上面这条命令后，在ambari界面查看该服务是否已经停止，如果停止了，则执行以下命令，否则请等待服务停止，然后再执行以下命令：

![](media/330469e8e46b9f47dea02e557ec9d47a.png)

**图56停止服务**

```
curl -u admin:admin -H "X-Requested-By: ambari" -X DELETE http://192.168.0.220:8080/api/v1/clusters/sugo_test/services/ASTRO_SUGO
```

![](media/4e72ddecd3f8ddc8bb0d2bd17b10aa03.png)

**图57删除服务操作**

如果命令没有返回错误，则可查看ambari界面，刷新后即可看到该服务已经被删除(如下图)。

![](media/25203eb03778b22c372ce70020d95c15.png)

**图58删除服务后的ambari界面**

## 6.4 增删Ambari-Agent ##

在已有Ambari的情况下，可能会遇到添加机器、扩展集群和迁移服务的需求，为了方便对集群的统一管理，增加Ambari-Agent则是一种比较合适的选择，增加Ambari-Agent后，通过Ambari对各服务进行迁移、增删等操作更加简便、友好。

增添Ambari-Agent主要分为主机准备、主机注册两个步骤，在完成主机注册后，即可在Ambari集群上对服务进行增删、迁移等。注：以下终端操作部分全部在Ambari-Server节点主机执行

### 6.4.1 增加Agent ###

第1步：主机准备

配置待添加主机的静态IP，修改hostname，注意hostname需要为二级域名，如：test1.sugo.vm，如果是离线主机，需要配置本地yum安装源库。

第2步：Agent环境准备

进入ambari-server所在主机终端，进入脚本目录/{安装包存储目录}/sugo_yum/deploy_scripts/centos6/ambari-agent(注：此处您的主机上可能不存在此目录，或者sugo_yum目录实际为yum，可以在github上下载脚本：<https://github.com/Datafruit/deploy_scripts>)，修改hosts文件，hosts文件用于写入需要添加的agent的主机名,
root用户的密码，该主机的IP地址
按行写入，每行代表一个主机(ambari-agent)，各项目之间以空格“ ”分割，例：

```
test3.sugo.vm 123456789 192.168.0.122
```

修改完成后保存，执行脚本pre_add_agent.sh，此脚本用于安装agent前的主机准备，包括安装jdk、配置ambari-server到该agent的ssh免密码登录、系统优化等，且jdk、ssh免密码可选择性安装，具体使用可通过如下命令进行查看

```
./pre_add_agent.sh –help
例：
./pre_add_agent.sh -http_port 81 -ambari_ip 192.168.0.120
```

第3步：注册主机

运行脚本add_agent.py，此脚本用于安装、注册ambari-agent，会在hosts文件中列出的主机上安装注册agent，运行此脚本需输入参数：集群名称 ambari-server的IP地址 例：

```
python add_agent.py testCluster 192.168.0.120
```

注：此脚本包含安装和注册两个部分，由于主机的配置等因素不同，安装所需时间也会不同，而注册需要安装完成后才可执行，此处设置安装等待时间为5秒，若因配置原因，脚本注册部分执行失败，重复执行该脚本即可

![](media/3649e50874a8082efeee680ebf273e2a.png)

**图59注册Ambari-Agent**

注册如果没有报错，则表明Agent注册成功，查看Web管理界面，如下图显示test3.sugo.vm注册成功，即可在此基础上管理相关服务。

![](media/9e8048e5db30567cc86cf00adcdc320f.png)

**图60 Ambari-Agent注册成功后的Web管理界面**

### 6.4.2 迁移服务 ###

在迁移服务之前，请注意，需要将下线节点所在的服务的数据转移到其它节点，所以需要先添加服务，此处以kafka为例：

第1步：添加kafka服务的组件kafka broker

选择新添加的主机，如此处的test3.sugo.vm，点击增加，选择Kafka
Broker，如图61所示：

![](media/b26eda869292062a6a734835d0c456fa.png)

**图61 增加Kafka Broker**

此时，返回kafka主界面，会看到Kafka Broker从1个变成了2个，如图63所示：

![](media/e0f89dc780b8217027d616711c1f4c71.png)

**图62 增加Kafka Broker后的Kafka主界面**

第2步：迁移数据

手工将test1.sugo.vm主机上Kafka的数据迁移至test3.sugo.vm上

第3步：删除旧的Kafka Broker

进入到Ambari界面旧主机（此处为test1.sugo.vm），停止该主机的Kafka
Broker，如图63所示：

![](media/571c242d35436320d56b395873270c21.png)

**图63 停止旧主机的Kafka Broker**

正确停止该Kafka
Broker后，点击该选项的删除按钮，删除完成后即将Kafka从test1.sugo.vm迁移到test3.sugo.vm上。如果只需要添加Kafka Broker，省略第3步。
