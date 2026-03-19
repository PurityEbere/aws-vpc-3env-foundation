# ==============================================================================
# DATA SOURCES
# ==============================================================================
data "aws_region" "current" {}

# ==============================================================================
# GATEWAY ENDPOINTS (Free)
# ==============================================================================

# S3 Gateway Endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
  
  vpc_endpoint_type = "Gateway"
  
  # CRITICAL: Associate with ALL route tables
  route_table_ids = concat(
    var.public_route_table_ids,
    var.private_app_route_table_ids,
    var.private_db_route_table_ids
  )
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-s3-endpoint"
    }
  )
}

# DynamoDB Gateway Endpoint
resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
  
  vpc_endpoint_type = "Gateway"
  
  route_table_ids = concat(
    var.public_route_table_ids,
    var.private_app_route_table_ids,
    var.private_db_route_table_ids
  )
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-dynamodb-endpoint"
    }
  )
}

# ==============================================================================
# SECURITY GROUP FOR INTERFACE ENDPOINTS
# ==============================================================================
resource "aws_security_group" "vpc_endpoints" {
  name_prefix = "${var.environment}-vpce-"
  description = "Security group for VPC interface endpoints"
  vpc_id      = var.vpc_id
  
  # INBOUND: Allow HTTPS from VPC
  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  
  # OUTBOUND: Allow all
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-vpce-sg"
    }
  )
  
  lifecycle {
    create_before_destroy = true
  }
}

# ==============================================================================
# INTERFACE ENDPOINTS (~$7.30/month per AZ)
# ==============================================================================

# Secrets Manager Endpoint
resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_app_subnet_ids
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true  # CRITICAL for SDK compatibility
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-secretsmanager-endpoint"
    }
  )
}

# SSM Endpoint (for Parameter Store, Session Manager)
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_app_subnet_ids
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-ssm-endpoint"
    }
  )
}

# ECR API Endpoint (for Docker image metadata)
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_app_subnet_ids
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-ecr-api-endpoint"
    }
  )
}

# ECR DKR Endpoint (for Docker image layers)
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_app_subnet_ids
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-ecr-dkr-endpoint"
    }
  )
}

# CloudWatch Logs Endpoint
resource "aws_vpc_endpoint" "logs" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_app_subnet_ids
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-logs-endpoint"
    }
  )
}
