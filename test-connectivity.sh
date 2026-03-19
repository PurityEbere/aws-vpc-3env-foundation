#!/bin/bash

set -e

VPC_ID=$1

if [ -z "$VPC_ID" ]; then
    echo "Usage: ./test-connectivity.sh <vpc-id>"
    echo ""
    echo "Get VPC ID with: terraform output -raw vpc_id"
    exit 1
fi

echo "Testing VPC: $VPC_ID"
echo ""

# Test 1: NAT Gateway Status Test
echo "✓ Checking NAT Gateway Status Test"
NAT_COUNT=$(aws ec2 describe-nat-gateways \
    --filter "Name=vpc-id,Values=$VPC_ID" "Name=state,Values=available" \
    --query 'length(NatGateways)' \
    --output text)

if [ "$NAT_COUNT" -eq 2 ]; then
    echo "   Found 2 available NAT Gateways"
else
    echo "   Expected 2 NAT Gateways, found $NAT_COUNT"
fi

# VPC Endpoint Status Test
echo ""
echo "✓ Checking VPC Endpoints Test"
ENDPOINT_COUNT=$(aws ec2 describe-vpc-endpoints \
    --filters "Name=vpc-id,Values=$VPC_ID" "Name=vpc-endpoint-state,Values=available" \
    --query 'length(VpcEndpoints)' \
    --output text)

if [ "$ENDPOINT_COUNT" -ge 7 ]; then
    echo "  Found $ENDPOINT_COUNT available VPC Endpoints"
else
    echo "  ⚠️  Expected 7+ endpoints, found $ENDPOINT_COUNT"
fi

# ubnet Count Test
echo ""
echo "✓ Checking Subnets Test"
SUBNET_COUNT=$(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" \
    --query 'length(Subnets)' \
    --output text)

if [ "$SUBNET_COUNT" -eq 6 ]; then
    echo "   Found 6 subnets (2 public, 2 app, 2 db)"
else
    echo "   Expected 6 subnets, found $SUBNET_COUNT"
fi

# Route Tables Test
echo ""
echo "✓ Checking Route Tables Test"
RT_COUNT=$(aws ec2 describe-route-tables \
    --filters "Name=vpc-id,Values=$VPC_ID" \
    --query 'length(RouteTables)' \
    --output text)

if [ "$RT_COUNT" -ge 5 ]; then
    echo "   Found $RT_COUNT route tables"
else
    echo "  ⚠️  Expected 6+ route tables, found $RT_COUNT"
fi

# Internet Gateway Test
echo ""
echo "✓ Checking Internet Gateway Test"
IGW_COUNT=$(aws ec2 describe-internet-gateways \
    --filters "Name=attachment.vpc-id,Values=$VPC_ID" \
    --query 'length(InternetGateways)' \
    --output text)

if [ "$IGW_COUNT" -eq 1 ]; then
    echo "   Internet Gateway attached"
else
    echo "   Expected 1 Internet Gateway, found $IGW_COUNT"
fi

echo ""
echo " All tests completed!"
echo ""
echo "Detailed VPC Info:"
aws ec2 describe-vpcs --vpc-ids $VPC_ID \
    --query 'Vpcs[0].[VpcId,CidrBlock,State,Tags[?Key==`Environment`].Value|[0]]' \
    --output table
