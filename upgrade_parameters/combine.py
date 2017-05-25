from xml_to_dict import *
from dict_to_xml import *
import sys, json

conf_dir1 = "/root/opt/apps"
conf_dir2 = "/"
conf_dir3 = "/root/"
file_name = ""




# 解析xml配置文件成dict，合并两个dict，再将dict转换成xml格式并生成合并后的xml配置文件
pm_file1 = sys.argv[1]
pm_file2 = sys.argv[2]
output_file = sys.argv[3]

f = open(output_file, "wb")

combined_dict = dict(json.loads(xmltodict(pm_file2)).items() + json.loads(xmltodict(pm_file1)).items())
#print a

output_xml = dicttoxml(combined_dict)
#print c

f.write(output_xml)
f.close()
