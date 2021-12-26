import boto3

print(boto3.__version__)

ec2 = boto3.client('ec2')
response = ec2.describe_instances()

instance_list = []

for reservation in response['Reservations']:
    for instance in reservation['Instances']:
        if(instance['State']['Name'] == 'running'):
            instanceName = ''
            publicIp = instance['PublicIpAddress']
            for instanceTag in instance['Tags']:
                if instanceTag["Key"] == 'Name':
                    instanceName = instanceTag["Value"]
            instance_list.append({'Instance Name': instanceName, 'Instance Public Ip': publicIp})
print(instance_list)