variable "region" {
  description = "AWS region to deploy into"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block, e.g. 10.0.0.0/16."
  }
}

variable "env" {
  description = "Environment name"
  type        = string

  validation {
    condition     = contains(["dev", "stg", "prod"], var.env)
    error_message = "env must be one of: dev, stg, prod."
  }
}

variable "use_localstack" {
  description = "Whether to point the AWS provider at a local LocalStack instance instead of real AWS"
  type        = bool
  default     = false
}

variable "localstack_endpoint" {
  description = "Endpoint URL for LocalStack (only used when use_localstack = true)"
  type        = string
  default     = "http://172.17.0.1:4566"
}