from AmbariService import AmbariService
import json
import time
base_url = 'http://192.168.0.220:8080/api/v1/clusters/sugo_test'
ambariService = AmbariService()

host_file = "host_service.json"
host_service = open(host_file)
json_array = json.loads(host_service.read())

for service in json_array:
    for key, value in service.items():
        ambariService.addservice(key, base_url)

        ambariService.addcomponent(value, base_url)

        ambariService.create_apply_config(key, base_url)


        ambariService.create_host_component(value, base_url)

        ambariService.installservice(key, base_url)
        time.sleep(3)
        #ambariService.start(key, base_url)
