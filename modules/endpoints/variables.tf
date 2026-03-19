variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "public_route_table_ids" {
  description = "Public route table IDs for Gateway Endpoints"
  type        = list(string)
}

variable "private_app_route_table_ids" {
  description = "Private app route table IDs for Gateway Endpoints"
  type        = list(string)
}

variable "private_db_route_table_ids" {
  description = "Private DB route table IDs for Gateway Endpoints"
  type        = list(string)
}

variable "private_app_subnet_ids" {
  description = "Private app subnet IDs for Interface Endpoints"
  type        = list(string)
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
