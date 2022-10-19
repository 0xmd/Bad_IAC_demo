from tkinter import N
import boto3
from botocore.exceptions import ClientError
import json
#import logging

AWS_REGION = 'ap-southeast-1'

#logger = logging.getLogger()
#logging.basicConfig(level=logging.INFO,
#                    format='%(asctime)s: %(levelname)s: %(message)s')

client = boto3.client("ec2", region_name=AWS_REGION)
badboys = []
N
try:
    response = client.describe_security_groups(
        Filters=[
            {
                "Name": "ip-permission.cidr",
                'Values': [
                    "0.0.0.0/0",
                ]
            },
        ]
    )
#    groups = json.dumps(response, indent=4, default=str)
#    print(groups)
    for sg in response['SecurityGroups']:
        badboys.append(sg['GroupId'])       
except ClientError as e:
    print(e)

if len(badboys)>0:
    print("Security Groups allowing unrestricted SSH:")
    for target in badboys:
        print(target)
        while ( nuke:=input("Delete? (y/n)").lower() ) not in {"y", "n"}: pass
        if nuke=='y': 
            try:
                #TODO: Find way to alter CIDR to the VPC range (after determining the VPC)
                #response2 = client.delete_security_group(GroupId=target)
                #if response2['ResponseMetadata']
                #print(response2)
                print('Security Group Deleted')
            except ClientError as e:
                print(e)
else:
    print("No results - All good")




#    "ResponseMetadata": {
#        "RequestId": "516bd927-799d-4457-b97b-4a91f142d31c",
#        "HTTPStatusCode": 200,


# trying to enum hosts linked to each SG before delete

#try:
#    response2 = client.describe_instances(
#        Filters=[
#            {
#                "Name": "network-interface.group-id",
#                'Values': [
#                    'target',
#                ]
#            },
#        ]
#    )