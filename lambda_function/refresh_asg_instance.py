import boto3
import botocore.exceptions
import logging


def as_get_instances(client, asgroup, NextToken=None):
    rsp = None
    if NextToken:
        rsp = client.describe_auto_scaling_instances(NextToken=NextToken)
    else:
        rsp = client.describe_auto_scaling_instances()

    for i in rsp['AutoScalingInstances']:
        if i['AutoScalingGroupName'] == asgroup:
            yield i['InstanceId']

    if 'NextToken' in rsp:
        for i in as_get_instances(client, asgroup, NextToken=rsp['NextToken']):
            yield i


def handler(event, context):
    region = event['region']
    autoscaling_group_name = event['autoscaling_group_name']
    asg_client = boto3.client('autoscaling', region_name=region)
    for instance in as_get_instances(asg_client, autoscaling_group_name):
        try:
            response = asg_client.terminate_instance_in_auto_scaling_group(InstanceId=instance,
                                                                           ShouldDecrementDesiredCapacity=False)
        except botocore.exceptions.ClientError as err:
            logging.error("Failed to terminate instance for Auto Scaling Group {}".format(autoscaling_group_name))
            raise err
