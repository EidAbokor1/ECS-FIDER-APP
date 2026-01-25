variable "region" {
  description = "aws region where resource will be created"
  type = string
  default = "eu-west-2"
}

variable "project_name" {
  description = "project named used for resource naming"
  type = string
  default = "fider"
}

variable "environment" {
  description = "The environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "vpc_cidr" {
  description = "cidr block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
    description = "list of availability zones"
    type = list(string)
    default = [ "eu-west-2a", "eu-west-2b" ]
}

variable "public_subnet_cidrs" {
    description = "cidr blocks for public subnets"
    type = list(string)
    default = [ "10.0.1.0/24","10.0.2.0/24" ]
}

variable "private_subnet_cidrs" {
    description = "cidr blocks for private subnets"
    type = list(string)
    default = [ "10.0.3.0/24","10.0.4.0/24" ]
}

variable "domain_name" {
  description = "Root domain name"
  type        = string
  default     = "project-hub.click"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "fider"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "fider"
}

variable "container_image" {
  description = "Docker image for the application"
  type        = string
  default     = "eabokor1/fider:amd64"
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 3000
}

variable "db_instance_class" {
  description = "RDS instance type"
  type = string
  default = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocate storage in gb"
  type = number
  default = 20
}

variable "db_engine_version" {
  description = "PostgresSQL engine version"
  type = string
  default = "17.6"
}

variable "db_password" {
  description = "Database password"
  type = string
  sensitive = true
}

variable "task_cpu" {
  description = "CPU units for the task"
  type        = string
  default     = "512"
}

variable "task_memory" {
  description = "Memory for the task in MB"
  type        = string
  default     = "1024"
}

variable "desired_count" {
  description = "Number of ECS tasks to run"
  type        = number
  default     = 2
}

variable "jwt_secret" {
  description = "JWT secret for authentication"
  type        = string
  sensitive   = true
}

variable "smtp_username" {
  description = "SMTP username for email"
  type        = string
  sensitive   = true
}

variable "smtp_password" {
  description = "SMTP password for email"
  type        = string
  sensitive   = true
}

variable "smtp_host" {
  description = "SMTP host for email"
  type        = string
  default     = "email-smtp.eu-west-2.amazonaws.com"
}

variable "smtp_port" {
  description = "SMTP port"
  type        = string
  default     = "587"
}

variable "email_noreply" {
  description = "No-reply email address"
  type        = string
  default     = "noreply@project-hub.click"
}

variable "admin_email" {
  description = "Admin email address for SES verification"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}
