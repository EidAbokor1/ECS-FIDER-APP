output "hosted_zone_id" {
  description = "Route 53 hosted zone ID"
  value       = aws_route53_zone.main.zone_id
}

output "hosted_zone_name_servers" {
  description = "Route 53 nameservers"
  value       = aws_route53_zone.main.name_servers
}

output "certificate_arn" {
  description = "ACM certificate ARN"
  value       = aws_acm_certificate_validation.main.certificate_arn
}

output "domain_name" {
  description = "Full domain name"
  value       = "${var.domain_name}"
}
