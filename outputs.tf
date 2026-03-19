
# VPC OUTPUTS

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr
}

output "vpc_arn" {
  description = "VPC ARN"
  value       = module.vpc.vpc_arn
}


# SUBNET OUTPUTS

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.subnets.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "Private app subnet IDs"
  value       = module.subnets.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  description = "Private DB subnet IDs"
  value       = module.subnets.private_db_subnet_ids
}

output "availability_zones" {
  description = "Availability zones used"
  value       = module.subnets.availability_zones
}


# NAT GATEWAY OUTPUTS

output "nat_gateway_ids" {
  description = "NAT Gateway IDs"
  value       = module.subnets.nat_gateway_ids
}

output "nat_gateway_public_ips" {
  description = "NAT Gateway public IP addresses"
  value       = module.subnets.nat_gateway_public_ips
}


# VPC ENDPOINT OUTPUTS

output "s3_endpoint_id" {
  description = "S3 VPC Endpoint ID"
  value       = module.endpoints.s3_endpoint_id
}

output "vpc_endpoint_security_group_id" {
  description = "VPC Endpoint Security Group ID"
  value       = module.endpoints.vpc_endpoint_security_group_id
}


# NETWORK SUMMARY (Human-Readable)

output "network_summary" {
  description = "Network configuration summary"
  value = {
    environment        = var.environment
    vpc_id             = module.vpc.vpc_id
    vpc_cidr           = module.vpc.vpc_cidr
    availability_zones = module.subnets.availability_zones
    public_subnets     = module.subnets.public_subnet_cidrs
    private_subnets    = module.subnets.private_app_subnet_cidrs
    database_subnets   = module.subnets.private_db_subnet_cidrs
    nat_gateways       = module.subnets.nat_gateway_public_ips
  }
}
