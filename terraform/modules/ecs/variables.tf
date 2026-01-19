variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ECS tasks"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "Security group ID for ECS tasks"
  type        = string
}

variable "target_group_arn" {
  description = "Target group ARN for load balancer"
  type        = string
}

variable "task_execution_role_arn" {
  description = "IAM role ARN for task execution"
  type        = string
}

variable "task_role_arn" {
  description = "IAM role ARN for task"
  type        = string
}

variable "container_image" {
  description = "Docker image for the application"
  type        = string
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
}

variable "task_cpu" {
  description = "CPU units for the task"
  type        = string
}

variable "task_memory" {
  description = "Memory for the task in MB"
  type        = string
}

variable "desired_count" {
  description = "Number of ECS tasks to run"
  type        = number
}

variable "domain_name" {
  description = "Full domain name for BASE_URL"
  type        = string
}

variable "database_url_secret_arn" {
  description = "ARN of database URL secret"
  type        = string
}

variable "jwt_secret_arn" {
  description = "ARN of JWT secret"
  type        = string
}

variable "smtp_username_secret_arn" {
  description = "ARN of SMTP username secret"
  type        = string
}

variable "smtp_password_secret_arn" {
  description = "ARN of SMTP password secret"
  type        = string
}

variable "email_noreply" {
  description = "No-reply email address"
  type        = string
}

variable "smtp_host" {
  description = "SMTP host"
  type        = string
}

variable "smtp_port" {
  description = "SMTP port"
  type        = string
}

variable "http_listener_arn" {
  description = "HTTP listener ARN"
  type        = string
}

variable "https_listener_arn" {
  description = "HTTPS listener ARN"
  type        = string
}
