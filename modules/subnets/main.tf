# ==============================================================================
# DATA SOURCES
# ==============================================================================
# Get list of available Availability Zones in current region
data "aws_availability_zones" "available" {
  state = "available"
}

# ==============================================================================
# LOCAL VALUES
# ==============================================================================
locals {
  # Use first 2 AZs (e.g., us-east-1a, us-east-1b)
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  # Subnet CIDR calculation
  # /16 VPC + 4 bits = /20 subnet (4,096 IPs each)
  subnet_newbits = 4
}

# ==============================================================================
# PUBLIC SUBNETS
# ==============================================================================
# Internet-facing subnets for ALB, Bastion, NAT Gateway
resource "aws_subnet" "public" {
  count = length(local.azs)

  vpc_id                  = var.vpc_id
  cidr_block              = cidrsubnet(var.vpc_cidr, local.subnet_newbits, count.index)
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true # Auto-assign public IPs

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-public-${local.azs[count.index]}"
      Type = "public"
      Tier = "dmz"
    }
  )
}

# ==============================================================================
# PRIVATE APP SUBNETS
# ==============================================================================
# Application layer subnets for ECS, Lambda, EC2
resource "aws_subnet" "private_app" {
  count = length(local.azs)

  vpc_id            = var.vpc_id
  cidr_block        = cidrsubnet(var.vpc_cidr, local.subnet_newbits, count.index + 2)
  availability_zone = local.azs[count.index]

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-private-app-${local.azs[count.index]}"
      Type = "private"
      Tier = "app"
      # EKS tag (for future Kubernetes use)
      "kubernetes.io/role/internal-elb" = "1"
    }
  )
}

# ==============================================================================
# PRIVATE DB SUBNETS
# ==============================================================================
# Database layer subnets for RDS, ElastiCache, Redshift
resource "aws_subnet" "private_db" {
  count = length(local.azs)

  vpc_id            = var.vpc_id
  cidr_block        = cidrsubnet(var.vpc_cidr, local.subnet_newbits, count.index + 4)
  availability_zone = local.azs[count.index]

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-private-db-${local.azs[count.index]}"
      Type = "private"
      Tier = "data"
    }
  )
}

# ==============================================================================
# ELASTIC IPs FOR NAT GATEWAYS
# ==============================================================================
# Static public IPs for NAT Gateways
resource "aws_eip" "nat" {
  count  = length(local.azs)
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-nat-eip-${local.azs[count.index]}"
    }
  )

  # Must wait for Internet Gateway
  depends_on = [var.internet_gateway_id]
}

# ==============================================================================
# NAT GATEWAYS
# ==============================================================================
# Provides internet access for private subnets (outbound only)
resource "aws_nat_gateway" "main" {
  count = length(local.azs)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-nat-${local.azs[count.index]}"
    }
  )

  depends_on = [var.internet_gateway_id]
}

# ==============================================================================
# NETWORK ACLs FOR DB SUBNETS
# ==============================================================================
# Stateless firewall protecting database layer
resource "aws_network_acl" "db" {
  vpc_id     = var.vpc_id
  subnet_ids = aws_subnet.private_db[*].id

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-db-nacl"
    }
  )
}

# ------------------------------------------------------------------------------
# INBOUND: Allow PostgreSQL (5432) from App Subnets
# ------------------------------------------------------------------------------
resource "aws_network_acl_rule" "db_ingress_postgres" {
  count = length(aws_subnet.private_app)

  network_acl_id = aws_network_acl.db.id
  rule_number    = 100 + count.index
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = aws_subnet.private_app[count.index].cidr_block
  from_port      = 5432
  to_port        = 5432
  egress         = false # INBOUND rule
}

# ------------------------------------------------------------------------------
# OUTBOUND: Allow Ephemeral Ports (CRITICAL!)
# ------------------------------------------------------------------------------
# TCP connections need return path for responses
resource "aws_network_acl_rule" "db_egress_ephemeral" {
  count = length(aws_subnet.private_app)

  network_acl_id = aws_network_acl.db.id
  rule_number    = 100 + count.index
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = aws_subnet.private_app[count.index].cidr_block
  from_port      = 1024
  to_port        = 65535
  egress         = true # OUTBOUND rule
}

# ------------------------------------------------------------------------------
# DENY ALL (Default Deny)
# ------------------------------------------------------------------------------
resource "aws_network_acl_rule" "db_ingress_deny_all" {
  network_acl_id = aws_network_acl.db.id
  rule_number    = 200
  protocol       = "-1" # All protocols
  rule_action    = "deny"
  cidr_block     = "0.0.0.0/0"
  egress         = false
}

resource "aws_network_acl_rule" "db_egress_deny_all" {
  network_acl_id = aws_network_acl.db.id
  rule_number    = 200
  protocol       = "-1"
  rule_action    = "deny"
  cidr_block     = "0.0.0.0/0"
  egress         = true
}
