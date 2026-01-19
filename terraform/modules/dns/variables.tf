variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "domain_name" {
  description = "Root domain name"
  type        = string
}


variable "alb_dns_name" {
  description = "ALB DNS name for Route 53 alias"
  type        = string
}

variable "alb_zone_id" {
  description = "ALB zone ID for Route 53 alias"
  type        = string
}
