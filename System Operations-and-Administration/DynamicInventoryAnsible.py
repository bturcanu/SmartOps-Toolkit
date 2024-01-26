#!/usr/bin/env python3

"""
Script: Dynamic Inventory for Ansible - AWS EC2
Author: Bogdan Turcanu
Description: Generates a dynamic inventory from AWS EC2 instances for use in Ansible.
Dependencies: boto3 (AWS SDK for Python), AWS credentials with EC2 read access.

Usage Instructions:
Install boto3: pip install boto3.
Configure AWS credentials (using AWS CLI or environment variables).
Modify AWS_REGIONS to include the AWS regions you want to query.
Set TAG_NAME to the tag used for grouping instances in Ansible.
Run the script to generate the inventory: python DynamicInventoryAnsible.py.

Running the Script:
The script outputs the inventory in JSON format, which can be directly used by Ansible.
You can integrate this script into Ansible by referencing it in the Ansible configuration or directly using it with the -i flag.

Notes: 
The script uses AWS EC2 API to fetch instance information and assumes that instances have a specific tag to group them in Ansible.
It's essential to have proper IAM permissions for the script to access EC2 instance information.
This script is a basic implementation. Depending on requirements, it can be extended to include more advanced filtering, support different cloud services, or handle other instance attributes.
"""

import boto3
import json

# Configuration
AWS_REGIONS = ['us-west-1', 'us-east-1']  # Regions to query for instances
TAG_NAME = 'AnsibleGroup'  # Tag name to use for grouping in Ansible

def fetch_ec2_instances(region):
    """
    Fetches EC2 instances from a specific AWS region
    """
    ec2 = boto3.client('ec2', region_name=region)
    instances = ec2.describe_instances()
    return instances

def parse_instances_to_inventory(instances):
    """
    Parses EC2 instances data to Ansible inventory format
    """
    inventory = {}
    for reservation in instances['Reservations']:
        for instance in reservation['Instances']:
            # Check if instance is running and has the required tag
            if instance['State']['Name'] == 'running':
                for tag in instance.get('Tags', []):
                    if tag['Key'] == TAG_NAME:
                        group_name = tag['Value']
                        if group_name not in inventory:
                            inventory[group_name] = {'hosts': []}
                        inventory[group_name]['hosts'].append(instance['PublicDnsName'])
    return inventory

def main():
    """
    Main function to generate Ansible inventory
    """
    all_instances = []
    for region in AWS_REGIONS:
        instances = fetch_ec2_instances(region)
        all_instances.extend(instances['Reservations'])

    inventory = parse_instances_to_inventory({'Reservations': all_instances})
    print(json.dumps(inventory, indent=4))

if __name__ == '__main__':
    main()
