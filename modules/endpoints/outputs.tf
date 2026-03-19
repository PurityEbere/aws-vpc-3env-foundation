output "s3_endpoint_id" {
  description = "S3 VPC Endpoint ID"
  value       = aws_vpc_endpoint.s3.id
}

output "dynamodb_endpoint_id" {
  description = "DynamoDB VPC Endpoint ID"
  value       = aws_vpc_endpoint.dynamodb.id
}

output "vpc_endpoint_security_group_id" {
  description = "Security Group ID for VPC Endpoints"
  value       = aws_security_group.vpc_endpoints.id
}

output "secretsmanager_endpoint_id" {
  description = "Secrets Manager VPC Endpoint ID"
  value       = aws_vpc_endpoint.secretsmanager.id
}

output "ssm_endpoint_id" {
  description = "SSM VPC Endpoint ID"
  value       = aws_vpc_endpoint.ssm.id
}

output "ecr_api_endpoint_id" {
  description = "ECR API VPC Endpoint ID"
  value       = aws_vpc_endpoint.ecr_api.id
}

output "ecr_dkr_endpoint_id" {
  description = "ECR DKR VPC Endpoint ID"
  value       = aws_vpc_endpoint.ecr_dkr.id
}

output "logs_endpoint_id" {
  description = "CloudWatch Logs VPC Endpoint ID"
  value       = aws_vpc_endpoint.logs.id
}
