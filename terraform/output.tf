output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.load_balancer.alb_dns_name
}

output "application_url" {
  description = "Application URL"
  value       = "https://${var.domain_name}"
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = module.database.db_endpoint
}

output "route53_nameservers" {
  description = "Route 53 nameservers - update these in your domain registrar"
  value       = module.dns.hosted_zone_name_servers
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.cluster_name
}

output "certificate_arn" {
  description = "ACM certificate ARN"
  value       = module.dns.certificate_arn
}
