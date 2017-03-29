# 集群部署文档（待续） #

## Ambari-server安装 ##

> 做好主机规划并准备主机，配置静态IP，修改主机hostname，安装相关软件包，如果是离线主机，需要配置本地安装源库，规划数据存储目录

注：  
hostname需设为二级域名，如test01.sugo.vm  
需要安装的相关软件包：wget、ntp、openssh-clients  
ambari-server主机的/etc/hosts文件，需添加集群各主机IP与hostname的映射  
另需在/etc/目录下新建ip.txt文件，并添加ambari-server主机外所有主机的hostname+root密码  
创建sugo_yum源存放目录，上传sugo_yum源  
在根目录下创建启动脚本  
启动启动脚本进行安装

```shell
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
chmod 755 pre_servers.sh sugo_yum_inst.sh
./pre_servers.sh $httppost $sugo_yum_dir $datadir
```
$httppost为http服务需要修改为的端口号  
$sugo_yum_dir为sugo_yum源的路径  
$datadir为数据存放路径  

  例：./pre_servers.sh 81 /data /data