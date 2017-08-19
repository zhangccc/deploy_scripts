#!/usr/bin/python
# -*- coding: UTF-8 -*-

# 使用DOM树的形式从空白文件生成一个XML

from xml.dom.minidom import Document
import re


def dicttoxml(inputfile):

    # 创建DOM文档对象
    doc = Document()

    # 创建根元素
    configuration = doc.createElement('configuration')
    doc.appendChild(configuration)

    for key, val in inputfile.items():
        text1 = key
        text2 = val

        # 创建根元素的子元素property
        property = doc.createElement('property')
        configuration.appendChild(property)

        # 创建元素property的子元素name
        name = doc.createElement('name')
        # 元素内容name写入
        name_text = doc.createTextNode(text1)
        name.appendChild(name_text)
        property.appendChild(name)

        # 创建元素property的子元素value
        value = doc.createElement('value')
        # 元素内容value写入
        value_text = doc.createTextNode(text2)
        value.appendChild(value_text)
        property.appendChild(value)

    # 返回DOM对象doc
    return re.sub(r'(<[^/][^<>]*[^/]>)\s*([^<>]*?)\s*(</[^<>]*>)', r'\1\2\3', doc.toprettyxml(indent='    '))