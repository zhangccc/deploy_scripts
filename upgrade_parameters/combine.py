#!/usr/bin/python
# -*- coding: UTF-8 -*-

from xml_to_dict import *
from dict_to_xml import *
import json, os, params


for dirPath1, dirNames1, fileNames1 in os.walk(params.conf_value):
    for f1 in fileNames1:

        pm_file1 = dirPath1 + f1
        pm_file2 = params.conf_pm + f1
        output_file = params.output_dir + f1
        print output_file

        f = open(output_file, "wb")

        combined_dict = dict(json.loads(xmltodict(pm_file2)).items() + json.loads(xmltodict(pm_file1)).items())

        output_xml = dicttoxml(combined_dict)

        f.write(output_xml)
        f.close()
