
# PUBLIC ROUTE TABLE

# One route table for all public subnets
resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-public-rt"
      Type = "public"
    }
  )
}

# Route to Internet Gateway (for internet access)
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0" # All traffic
  gateway_id             = var.internet_gateway_id
}

# Associate public subnets with this route table
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_ids)

  subnet_id      = var.public_subnet_ids[count.index]
  route_table_id = aws_route_table.public.id
}


# PRIVATE APP ROUTE TABLES (One per AZ)

# Separate route table per AZ for high availability
resource "aws_route_table" "private_app" {
  count  = length(var.private_app_subnet_ids)
  vpc_id = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-private-app-rt-${var.availability_zones[count.index]}"
      Type = "private"
      Tier = "app"
    }
  )
}

# Route to NAT Gateway (per AZ)
resource "aws_route" "private_app_nat" {
  count = length(var.private_app_subnet_ids)

  route_table_id         = aws_route_table.private_app[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.nat_gateway_ids[count.index]
}

# Associate app subnets with their AZ's route table
resource "aws_route_table_association" "private_app" {
  count = length(var.private_app_subnet_ids)

  subnet_id      = var.private_app_subnet_ids[count.index]
  route_table_id = aws_route_table.private_app[count.index].id
}


# PRIVATE DB ROUTE TABLES (One per AZ)

# DB subnets have NO default route (no internet access)
resource "aws_route_table" "private_db" {
  count  = length(var.private_db_subnet_ids)
  vpc_id = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-private-db-rt-${var.availability_zones[count.index]}"
      Type = "private"
      Tier = "data"
    }
  )
}

# NO default route! Traffic only to:
# - VPC CIDR (automatically included as "local")
# - VPC Endpoints (added automatically)

# Associate DB subnets with their route tables
resource "aws_route_table_association" "private_db" {
  count = length(var.private_db_subnet_ids)

  subnet_id      = var.private_db_subnet_ids[count.index]
  route_table_id = aws_route_table.private_db[count.index].id
}
