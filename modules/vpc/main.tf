# ==============================================================================
# VPC Resource
# ==============================================================================
# This creates the VPC - an isolated network in AWS
resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  
  # Enable DNS hostnames (required for RDS endpoints to work)
  enable_dns_hostnames = true
  
  # Enable AWS DNS resolver
  enable_dns_support = true
  
  # Tags for identification
  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-vpc"
      Environment = var.environment
    }
  )
}

# ==============================================================================
# Internet Gateway
# ==============================================================================
# This allows resources in public subnets to reach the internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-igw"
    }
  )
}
