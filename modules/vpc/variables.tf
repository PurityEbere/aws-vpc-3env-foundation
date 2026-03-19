
# Environment Variable

variable "environment" {
  description = "Environment name (prod, test, dev)"
  type        = string

  # Validation: Only allow these values
  validation {
    condition     = contains(["prod", "test", "dev"], var.environment)
    error_message = "Environment must be prod, test, or dev."
  }
}


# CIDR Block Variable

variable "cidr_block" {
  description = "VPC CIDR block - must not overlap with other VPCs"
  type        = string

  # Validation: Must be a valid CIDR
  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "Must be a valid CIDR block (e.g., 10.0.0.0/16)."
  }
}


# Tags Variable

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
