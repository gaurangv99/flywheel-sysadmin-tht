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

variable "container_port" {
  description = "Container port for traffic"
  type        = number
  default     = 5001
}

variable "postgres_allocated_storage" {
  description = "Allocated storage for postgres DB"
  type        = number
  default     = 20
}

variable "postgres_backup_window" {
  description = "Bakup window for postgres DB"
  type        = string
  default     = "07:00-09:00"
}

variable "postgres_backup_retention_period" {
  description = "Number of days backup has to be retained"
  type        = number
  default     = 5
}

variable "ecs_min_asg_count" {
  description = "Min capacity for asg scaling"
  type        = number
  default     = 1
}

variable "ecs_max_asg_count" {
  description = "Max capacity for asg scaling"
  type        = number
  default     = 6
}

variable "ecs_cpu" {
  description = "CPU units for ecs tasks"
  type        = number
  default     = 256
}

variable "ecs_memory" {
  description = "Memory for ecs tasks"
  type        = number
  default     = 512
}

variable "ecs_scale_down_steps" {
  type = list(object({
    upper_bound = number
    lower_bound = number
    adjustment  = number
  }))
  default = [
    { upper_bound = 0, lower_bound = -5, adjustment = -1 },
    { upper_bound = -5, lower_bound = -10, adjustment = -2 }
  ]
}

variable "ecs_scale_up_steps" {
  type = list(object({
    upper_bound = number
    lower_bound = number
    adjustment  = number
  }))
  default = [
    { upper_bound = 5, lower_bound = 0, adjustment = 1 },
    { upper_bound = 10, lower_bound = 5, adjustment = 2 }
  ]
}

variable "alb_health_check_path" {
  description = "ALB healthcheck path"
  type        = string
  default     = "/"
}

variable "alb_healthcheck_interval" {
  description = "Alb healthcheck interval"
  type        = number
  default     = 10
}

variable "alb_healthcheck_timeout" {
  description = "Alb healthcheck timeout"
  type        = number
  default     = 5
}

variable "alb_healthy_threshold" {
  description = "Alb healthy threshold"
  type        = number
  default     = 2
}

variable "alb_unhealthy_threshold" {
  description = "Alb unhealthy threshold"
  type        = number
  default     = 10
}
