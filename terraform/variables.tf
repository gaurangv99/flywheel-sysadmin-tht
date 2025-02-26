variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.124.0.0/20"
}

variable "availability_zones" {
  description = "Region AZs"
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "Public Subnets CIDRs"
  default     = ["10.124.0.0/23", "10.124.2.0/23", "10.124.4.0/23"]
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private Subnets CIDRs"
  default     = ["10.124.6.0/23", "10.124.8.0/23", "10.124.10.0/23"]
  type        = list(string)
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "db_instance_class" {
  description = "The instance class for the RDS cluster"
  type        = string
  default     = "db.t4g.micro"
}

variable "employee_registry_image" {
  description = "Employee registry image name"
  type        = string
}

variable "vpc_id" {
  description = "vpc_id"
  type        = string
}

variable "private_subnets_ids" {
  description = "Private Subnets"
  type        = list(string)
}

variable "public_subnets_ids" {
  description = "Public Subnets"
  type        = list(string)
}

variable "vpc_name" {
  description = "VPC Name"
  type        = string
}