#!/usr/bin/python
# -*- coding: UTF-8 -*-

from xml.dom.minidom import parse
import xml.dom.minidom
import json



class Xmltodict:
    def xmltodict(self, input_file):

        # 使用minidom解析器打开 XML 文档
        DOMTree = xml.dom.minidom.parse(input_file)
        collection = DOMTree.documentElement

        # 在集合中获取所有配置信息
        properties = collection.getElementsByTagName("property")

        # 打印每个配置的详细信息
        json_obj = {}
        for property in properties:
            name = property.getElementsByTagName('name')[0].childNodes[0].data
            value = property.getElementsByTagName('value')
            if value is None or len(value) == 0:
               print 'null'
               continue

            if len(value[0].childNodes) == 0:
                print 'childNodes null'
                continue
            value = value[0].childNodes[0].data
            json_obj[name] = value

        encode_json = json.dumps(json_obj)
        return encode_json