
# PUBLIC SUBNET OUTPUTS

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  value       = aws_subnet.public[*].cidr_block
}


# PRIVATE APP SUBNET OUTPUTS

output "private_app_subnet_ids" {
  description = "List of private app subnet IDs"
  value       = aws_subnet.private_app[*].id
}

output "private_app_subnet_cidrs" {
  description = "List of private app subnet CIDR blocks"
  value       = aws_subnet.private_app[*].cidr_block
}


# PRIVATE DB SUBNET OUTPUTS

output "private_db_subnet_ids" {
  description = "List of private DB subnet IDs"
  value       = aws_subnet.private_db[*].id
}

output "private_db_subnet_cidrs" {
  description = "List of private DB subnet CIDR blocks"
  value       = aws_subnet.private_db[*].cidr_block
}


# NAT GATEWAY OUTPUTS

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.main[*].id
}

output "nat_gateway_public_ips" {
  description = "List of NAT Gateway public IP addresses"
  value       = aws_eip.nat[*].public_ip
}


# AVAILABILITY ZONE OUTPUTS

output "availability_zones" {
  description = "List of availability zones used"
  value       = local.azs
}
