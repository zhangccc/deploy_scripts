### 安装前检查

1. 检查容量够不够，如果用的是已有的hdfs，看下副本数
2. 检查`/data1` `/data2`，是否存在，如果已经存在，看所在磁盘分区剩余容量是否足够，如果不够则移动到剩余容量大的分区
2. 检查`/etc/hosts`有没记录

### 安装后检查
1. 检查`jps` `jstack`命令是否存在，(如果集群有其他服务，只在`druid`用户下的`~/.bashrc`配置jdk环境变量)
2. 如果部署了gateway测试csv是否能导入

### 更新
1. 更新ambari安装脚本，目录`/var/lib/ambari-server/resources/stacks/SG/1.0/services/`
1. yum目录备份安装包，备份包名称为`“包名” + 日期` 如`druid-1.0.0-bin.tar.gz.20170513`
2. 下载新的安装包到yum目录（如无特殊要求，使用saas版本安装包）
3. 界面点击更新
