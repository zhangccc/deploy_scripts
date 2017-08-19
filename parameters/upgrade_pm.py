#!/usr/bin/python
# -*- coding: UTF-8 -*-

import json, urllib2, time, os
from xml_to_dict import *

xml_to_dict = Xmltodict()

conf_version = "version" + str(time.time())


# direct of parameters   eg: sugo-core-site.xml
import params
conf_dir = params.output_dir

# 遍历配置文件夹，得到配置文件名及其路径
for dirPath1, dirNames1, fileNames1 in os.walk(conf_dir):
    for f1 in fileNames1:
        pm_name1 = os.path.join(f1)
        pm1 = os.path.join(dirPath1, f1)
        pm_json1 = json.loads(xml_to_dict.xmltodict(pm1))

        # 去除配置文件名的后缀.xml
        pos = pm_name1.rfind(".")
        pm = pm_name1[:pos]

        # create configuration
        data2 = {}
        data2["type"] = pm
        data2["tag"] = conf_version
        data2["properties"] = pm_json1

        request = urllib2.Request(params.base_url + "/configurations")
        request.add_header('Authorization', 'Basic YWRtaW46YWRtaW4=')
        request.add_header('X-Requested-By', 'ambari')
        response = urllib2.urlopen(request, json.dumps(data2))
        print response.read()

        # apply configuration
        data3 = {}
        desired_configs = {}
        json_obj2 = {}
        data3["Clusters"] = desired_configs
        desired_configs["desired_configs"] = json_obj2
        json_obj2["type"] = pm
        json_obj2["tag"] = conf_version

        request = urllib2.Request(params.base_url)
        request.add_header('Authorization', 'Basic YWRtaW46YWRtaW4=')
        request.add_header('X-Requested-By', 'ambari')
        request.get_method = lambda: "PUT"
        response = urllib2.urlopen(request, json.dumps(data3))
        print response.read()


