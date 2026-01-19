output "domain_identity_arn" {
  description = "SES domain identity ARN"
  value       = aws_ses_domain_identity.main.arn
}

output "domain_identity_verification_token" {
  description = "SES domain verification token"
  value       = aws_ses_domain_identity.main.verification_token
}

output "email_identity_arn" {
  description = "SES email identity ARN"
  value       = aws_ses_email_identity.admin.arn
}

output "dkim_tokens" {
  description = "DKIM tokens"
  value       = aws_ses_domain_dkim.main.dkim_tokens
}
