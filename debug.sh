#!/bin/bash -x

if [[ "$#" -ne 3 ]]; then
  echo "Usage: $0 <region> <stack-name> <key-name>" >&2
  exit 1
fi

REGION=$1
STACK=$2
KEYNAME=$3

VPC=$(aws --region ${REGION} cloudformation describe-stack-resource --stack-name ${STACK} --query 'StackResourceDetail.PhysicalResourceId' --output text --logical-resource-id VPC)
PublicSubnet0=$(aws --region ${REGION} cloudformation describe-stack-resource --stack-name ${STACK} --query 'StackResourceDetail.PhysicalResourceId' --output text --logical-resource-id PublicSubnet0)
PublicSubnet1=$(aws --region ${REGION} cloudformation describe-stack-resource --stack-name ${STACK} --query 'StackResourceDetail.PhysicalResourceId' --output text --logical-resource-id PublicSubnet1)
PublicSubnet2=$(aws --region ${REGION} cloudformation describe-stack-resource --stack-name ${STACK} --query 'StackResourceDetail.PhysicalResourceId' --output text --logical-resource-id PublicSubnet2)
DefaultSecurityGroup=$(aws --region ${REGION} ec2 describe-security-groups --query 'SecurityGroups[0].GroupId' --output text --filter Name=group-name,Values=default Name=vpc-id,Values=${VPC})
aws --region ${REGION} \
    cloudformation create-stack \
    --template-body file://debug.yaml \
    --stack-name ${STACK}-debug \
    --capabilities CAPABILITY_IAM --parameters \
      ParameterKey=KeyName,ParameterValue=${KEYNAME} \
      ParameterKey=VPC,ParameterValue=${VPC} \
      ParameterKey=PublicSubnet0,ParameterValue=${PublicSubnet0} \
      ParameterKey=PublicSubnet1,ParameterValue=${PublicSubnet1} \
      ParameterKey=PublicSubnet2,ParameterValue=${PublicSubnet2} \
      ParameterKey=DefaultSecurityGroup,ParameterValue=${DefaultSecurityGroup}
