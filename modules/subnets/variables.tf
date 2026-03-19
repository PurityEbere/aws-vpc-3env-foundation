variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where subnets will be created"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block for subnet calculations"
  type        = string
}

variable "internet_gateway_id" {
  description = "Internet Gateway ID (for NAT Gateway dependency)"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
