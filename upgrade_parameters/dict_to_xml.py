# encoding:utf-8

# 使用DOM树的形式从空白文件生成一个XML

from xml.dom.minidom import Document
import json


def dicttoxml(inputfile):

    # 定义输入文件和输出文件
    # c = open(input_file)
    # d = open(output_file, "wb")
    # inputfile = json.loads(input_file)

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

    # 将DOM对象doc写入文件
    return doc.toprettyxml(indent='')
    # d.write(doc.toprettyxml(indent=''))
    # d.close()
