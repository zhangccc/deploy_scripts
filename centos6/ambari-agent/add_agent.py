#!/usr/bin/python
#coding=utf-8

import json, os, sys, time
import urllib2

# need to be altered
cluster_name = sys.argv[1]
ambari_server_ip = sys.argv[2]

agent_file = "hosts"
a = open(agent_file, "r+")
hosts = []

for line in a:
    host = line.split(" ")[0]
    hosts.append(host)


sshkey_file = "/root/.ssh/id_rsa"
f = open(sshkey_file, "r+")
sshkey = f.read().strip('\n')
url0 = "http://" + ambari_server_ip + ":8080/api/v1/bootstrap"

# install ambari-agent
data1 = {}
serviceinfo = {}
data1["verbose"] = "true"
data1["hosts"] = hosts
data1["sshKey"] = sshkey
data1["user"] = "root"
data1["userRunAs"] = "root"

request = urllib2.Request(url0)
request.add_header('Authorization', 'Basic YWRtaW46YWRtaW4=')
request.add_header('Content-Type', 'application/json')
request.add_header('X-Requested-By', 'ambari')
response = urllib2.urlopen(request, json.dumps(data1), 10)
print response.read()
f.close()

time.sleep(5)

# register ambari-agent
for host in hosts:
    url1 = "http://" + ambari_server_ip + ":8080/api/v1/clusters/" + cluster_name + "/hosts/" + host
    request_register = urllib2.Request(url1)
    request_register.add_header('Authorization', 'Basic YWRtaW46YWRtaW4=')
    request_register.add_header('Content-Type', 'application/json')
    request_register.add_header('X-Requested-By', 'ambari')
    response2 = urllib2.urlopen(request_register, "", 60)
    print response2.read()