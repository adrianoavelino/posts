#!/bin/bash

echo "########### script 01 - Creating lambda function ###########"
awslocal cloudformation create-stack \
--stack-name example-lambda-stack \
--capabilities CAPABILITY_NAMED_IAM \
--template-body file://cloudformation.yml \

sleep 10
echo "########### script 01 - Lambda function has been created ###########"
