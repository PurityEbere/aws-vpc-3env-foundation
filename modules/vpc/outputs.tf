
# VPC ID Output

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}


# VPC CIDR Output

output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}


# Internet Gateway ID Output

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}


# VPC ARN Output

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = aws_vpc.main.arn
}
