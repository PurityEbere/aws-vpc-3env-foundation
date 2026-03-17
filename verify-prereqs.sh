#!/bin/bash

echo "========================================="
echo "Verifying Prerequisites"
echo "========================================="
echo ""

# Check AWS CLI
echo -n "AWS CLI: "
if command -v aws &> /dev/null; then
    aws --version
else
    echo "NOT INSTALLED"
    exit 1
fi

# Check Terraform
echo -n "Terraform: "
if command -v terraform &> /dev/null; then
    terraform --version | head -n 1
else
    echo  NOT INSTALLED"
    exit 1
fi

# Check Git
echo -n "Git: "
if command -v git &> /dev/null; then
    git --version
else
    echo "NOT INSTALLED"
    exit 1
fi

# Check AWS credentials
echo -n "AWS Credentials: "
if aws sts get-caller-identity &> /dev/null; then
    echo "CONFIGURED"
else
    echo "NOT CONFIGURED"
    exit 1
fi

echo ""
echo "========================================="
echo "All prerequisites verified!"
echo "========================================="
