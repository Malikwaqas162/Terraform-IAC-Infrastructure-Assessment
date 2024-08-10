variable "region" {
  description = "The AWS region to create resources in"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr_a" {
  description = "CIDR block for the public subnet A"
  type        = string
}

variable "public_subnet_cidr_b" {
  description = "CIDR block for the public subnet B"
  type        = string
}

variable "private_subnet_cidr_a" {
  description = "CIDR block for the private subnet A"
  type        = string
}

variable "private_subnet_cidr_b" {
  description = "CIDR block for the private subnet B"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "db_user" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}
