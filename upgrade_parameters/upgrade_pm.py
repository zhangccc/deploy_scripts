#!/usr/bin/python
#coding=utf-8

import json
import urllib2
import time
import os
from ../service_inst/Parse_xml import Parse_xml

# Create configuration
def create_apply_config(self, service_name, base_url):
    # direct of parameters   eg: sugo-core-site.xml
    conf_dir = "/var/lib/ambari-server/resources/stacks/SG/1.0/services/" + service_name + "/configuration/"
    if service_name == 'MAPREDUCE_SUGO':
        conf_dir = "/var/lib/ambari-server/resources/stacks/SG/1.0/services/YARN_SUGO/configuration-mapred/"

    changed_conf_dir = "changed_configuration/"

    # 遍历配置文件夹，得到配置文件名及其路径
    for dirPath1, dirNames1, fileNames1 in os.walk(conf_dir):
        for f1 in fileNames1:
            pm_name1 = os.path.join(f1)
            pm1 = os.path.join(dirPath1, f1)
            pm_json1 = parse_xml.Parse_xml(pm1)

            # 去除配置文件名的后缀.xml
            pos = pm_name1.rfind(".")
            pm = pm_name1[:pos]

            # 遍历需要修改的配置文件所在的文件夹，得到需要修改的配置文件名pm_name01
            for dirPath01, dirNames01, fileNames01 in os.walk(changed_conf_dir):
                for f01 in fileNames01:
                    pm_name01 = os.path.join(f01)
                    pm01 = os.path.join(dirPath01, f01)
                    pm_json01 = parse_xml.Parse_xml(pm01)

                    if pm_name1 != pm_name01:
                        continue
                    else:

                        # 判断配置文件是否需要修改，如果是，则update解析后的文件
                        pm_json1.update(pm_json01)
                        break

                # create configuration
                data2 = {}
                data2["type"] = pm
                data2["tag"] = conf_version
                data2["properties"] = pm_json1

                request = urllib2.Request(base_url + "/configurations")
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

                request = urllib2.Request(base_url)
                request.add_header('Authorization', 'Basic YWRtaW46YWRtaW4=')
                request.add_header('X-Requested-By', 'ambari')
                request.get_method = lambda: "PUT"
                response = urllib2.urlopen(request, json.dumps(data3))
                print response.read()