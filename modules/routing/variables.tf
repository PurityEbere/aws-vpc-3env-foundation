variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "internet_gateway_id" {
  description = "Internet Gateway ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_app_subnet_ids" {
  description = "List of private app subnet IDs"
  type        = list(string)
}

variable "private_db_subnet_ids" {
  description = "List of private DB subnet IDs"
  type        = list(string)
}

variable "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
