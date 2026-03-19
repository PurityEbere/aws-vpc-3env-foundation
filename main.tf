
# TERRAFORM CONFIGURATION

terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


# PROVIDER CONFIGURATION

provider "aws" {
  region = var.aws_region

  # Default tags applied to ALL resources
  default_tags {
    tags = {
      Project     = "VPC-Foundation"
      ManagedBy   = "Terraform"
      Environment = var.environment
      Repository  = "VPC-Foundation"
    }
  }
}


# LOCAL VALUES

locals {
  common_tags = {
    Project     = "VPC-Foundation"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}


# VPC MODULE

module "vpc" {
  source = "./modules/vpc"

  environment = var.environment
  cidr_block  = var.vpc_cidr
  tags        = local.common_tags
}


# SUBNETS MODULE

module "subnets" {
  source = "./modules/subnets"

  environment         = var.environment
  vpc_id              = module.vpc.vpc_id              # ← From VPC module
  vpc_cidr            = module.vpc.vpc_cidr            # ← From VPC module
  internet_gateway_id = module.vpc.internet_gateway_id # ← From VPC module
  tags                = local.common_tags
}


# ROUTING MODULE

module "routing" {
  source = "./modules/routing"

  environment            = var.environment
  vpc_id                 = module.vpc.vpc_id
  internet_gateway_id    = module.vpc.internet_gateway_id
  public_subnet_ids      = module.subnets.public_subnet_ids      # ← From Subnets module
  private_app_subnet_ids = module.subnets.private_app_subnet_ids # ← From Subnets module
  private_db_subnet_ids  = module.subnets.private_db_subnet_ids  # ← From Subnets module
  nat_gateway_ids        = module.subnets.nat_gateway_ids        # ← From Subnets module
  availability_zones     = module.subnets.availability_zones     # ← From Subnets module
  tags                   = local.common_tags
}


# ENDPOINTS MODULE

module "endpoints" {
  source = "./modules/endpoints"

  environment                 = var.environment
  vpc_id                      = module.vpc.vpc_id
  vpc_cidr                    = module.vpc.vpc_cidr
  public_route_table_ids      = [module.routing.public_route_table_id]     # ← From Routing module
  private_app_route_table_ids = module.routing.private_app_route_table_ids # ← From Routing module
  private_db_route_table_ids  = module.routing.private_db_route_table_ids  # ← From Routing module
  private_app_subnet_ids      = module.subnets.private_app_subnet_ids
  tags                        = local.common_tags
}
