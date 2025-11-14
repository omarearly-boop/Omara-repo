variable "aws_region" {
  description = "The AWS region to deploy the infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "The name of the project, used as a prefix for resources"
  type        = string
  default     = "wikijs-opsguru"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets_cidr" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets_cidr" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "database_subnets_cidr" {
  description = "List of CIDR blocks for database subnets"
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24"]
}

variable "db_instance_type" {
  description = "The RDS instance type"
  type        = string
  default     = "db.t3.small"
}

variable "db_username" {
  description = "Master username for the RDS instance"
  type        = string
  default     = "wikijsadmin"
}

variable "db_password" {
  description = "Master password for the RDS instance"
  type        = string
  default     = "ChangeMe123!" # NOTE: In a real deployment, this should be managed by AWS Secrets Manager or a secure variable store.
}

variable "desired_ecs_tasks" {
  description = "The desired number of ECS tasks (Wiki.js instances)"
  type        = number
  default     = 2
}

variable "ssl_certificate_arn" {
  description = "ARN of the ACM certificate for the ALB"
  type        = string
  # NOTE: This must be provided by the user in a real deployment. Using a placeholder.
  default     = "arn:aws:acm:us-east-1:123456789012:certificate/example-cert-id"
}
