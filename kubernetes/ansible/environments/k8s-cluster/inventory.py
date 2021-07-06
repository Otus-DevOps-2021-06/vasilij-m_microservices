#!/usr/bin/env python3.8
import requests
import json
import os
import argparse


yandexPassportOauthToken = os.environ.get('yandexPassportOauthToken')
FOLDER_ID = os.environ.get('ycFolderIdDefault')
IAM_URL = 'https://iam.api.cloud.yandex.net/iam/v1/tokens'
instance_url = 'https://compute.api.cloud.yandex.net/compute/v1/instances?folderId=' + FOLDER_ID


response = requests.post(
    IAM_URL, json={'yandexPassportOauthToken': yandexPassportOauthToken})
iamToken = json.loads(response.text)['iamToken']
response = requests.get(instance_url, headers={
                        'Authorization': 'Bearer ' + iamToken})


instances = json.loads(response.text)['instances']


parser = argparse.ArgumentParser(
    description='Arguments for Ansible dynamic inventory')
parser.add_argument('--list', action='store_true',
                    help='create json inventory')
parser.add_argument('--host', type=str, help='print host variables')


args = parser.parse_args()


master_hosts = []
worker_hosts = []
all_hosts = []
hosts_ip = []
hostvars = {}


for instance in instances:
    if 'k8s-master' in instance['name']:
        master_hosts.append(instance['name'])
    elif 'k8s-worker' in instance['name']:
        worker_hosts.append(instance['name'])

    all_hosts.append(instance['name'])
    hosts_ip.append(instance['networkInterfaces'][0]
                    ['primaryV4Address']['oneToOneNat']['address'])


i = 0


for hostname in all_hosts:
    host = {hostname: {'ansible_host': hosts_ip[i]}}
    hostvars.update(host)
    i += 1


inventory = { "k8s-master": { "hosts": master_hosts }, "k8s-worker": { "hosts": worker_hosts }, "_meta": { "hostvars": hostvars } }


if args.list:
    print(json.dumps(inventory, indent=2))
elif args.host:
    print(inventory["_meta"]["hostvars"][args.host])
