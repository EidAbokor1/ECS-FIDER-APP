variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "domain_name" {
  description = "Domain name for SES verification"
  type        = string
}

variable "hosted_zone_id" {
  description = "Route 53 hosted zone ID for DNS records"
  type        = string
}

variable "admin_email" {
  description = "Admin email address for SES verification"
  type        = string
}
