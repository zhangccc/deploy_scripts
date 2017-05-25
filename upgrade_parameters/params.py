#!/usr/bin/python
# -*- coding: UTF-8 -*-

from upgrade_pm import upgrade_config
from combine import combine_xml

# 定义配置文件路径及服务名
service_name = "PIO_SUGO"
base_url = "http://192.168.0.159:8080/api/v1/clusters/testcluster00"

conf_value = "configuration/" + service_name + "/download_pm/"
conf_pm = "/var/lib/ambari-server/resources/stacks/SG/1.0/services/" + service_name + "/configuration/"
output_dir = "configuration/" + service_name + "/upgrade_pm/"

# 合并xml配置文件
combine_xml()

# 更新ambari上service配置
upgrade_config(service_name, base_url)