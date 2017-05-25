#!/usr/bin/python
# -*- coding: UTF-8 -*-

# 定义配置文件路径及服务名
service_name = "PIO_SUGO"
base_url = "http://192.168.0.159:8080/api/v1/clusters/testcluster00"
conf_pm = "/var/lib/ambari-server/resources/stacks/SG/1.0/services/" + service_name + "/configuration/"


conf_value = "configuration/" + service_name + "/download_pm/"
output_dir = "configuration/" + service_name + "/upgrade_pm" + "/"

