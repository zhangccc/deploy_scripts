# 集群部署文档（待续） #

## 安装之前 ##
### 主机准备
> 做好主机规划并准备主机，配置静态IP，修改主机hostname，安装相关软件包，如果是离线主机，需要配置本地安装源库，规划数据存储目录

注：  
hostname需设为三级域名，如test01.sugo.vm  
需要安装的相关软件包：wget、ntp、openssh-clients  
ambari-server主机的/etc/hosts文件，需添加集群各主机IP与hostname的映射

###搭建本地yum源
> 使用任意一种http服务器，如tomcat，将yum源文件sugo_yum.zip解压到http服务器的内容目录，或其它目录并用符号链接连接http内容目录  
> 修改http服务端口号为81或其它，创建数据存储目录，开启http服务，下载脚本

yum install -y httpd    
vi /etc/httpd/conf/httpd.conf   
 
    Listen 81
mkdir /data   #如果已经存在则无需创建  
cd /data  
上传yum源sugo\_yum.zip  
unzip sugo\_yum.zip  
ln -s /data/sugo_yum /var/www/html  
service httpd start  
  
wget http://\`hostname`:81/sugo\_yum/SG/centos6/1.0/deploy\_scripts.tar.gz  
tar -zxvf deploy\_scripts.tar.gz  
cd deploy\_scripts/os  
修改ip.txt，按“hostname+密码”的格式输入ambari-server外其它所有主机的信息  
chmod 755 create\_datadir.sh init\_all\_hosts.sh init\_centos6.sh init\_process.sh scp\_hosts.sh  
./create_datadir.sh [$datadir]  
  
>[$datadir]为数据存储根目录，例如上面的/data，如果准备阶段没有规划该目录，则默认为空，执行时不输入该参数
  
  

###系统基本参数优化
>分发hosts文件到其它主机  
>运行参数优化脚本

./scp\_hosts.sh  
./init\_process.sh

###ambari-server安装
>直接运行脚本即可  
>此处默认http服务和ambari-server安装在同一台主机上  

cd /deploy_scripts/server  
./ambari-server-inst.sh  
  
浏览器访问IP:8080，选择服务栈，注册集群主机等  
参数：  
**Grafana Admin Password:** admin admin

  


####解决问题
- 简化部署流程
- 减少手动操作
- 减少部署错误
- 缩减部署时间
- 集群主机数量较多时，优势会更加明显

####不足
集群部署过程中会出现文件目录不同、IP与hostname的映射等诸多细节的不同，脚本基于流程编写，并没有将所有可能出现变化的细节参数化，仅参数化部分较重要的输入信息


