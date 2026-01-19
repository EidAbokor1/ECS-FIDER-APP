output "database_url_secret_arn" {
  description = "ARN of database URL secret"
  value       = aws_secretsmanager_secret.database_url.arn
}

output "jwt_secret_arn" {
  description = "ARN of JWT secret"
  value       = aws_secretsmanager_secret.jwt_secret.arn
}

output "smtp_username_secret_arn" {
  description = "ARN of SMTP username secret"
  value       = aws_secretsmanager_secret.smtp_username.arn
}

output "smtp_password_secret_arn" {
  description = "ARN of SMTP password secret"
  value       = aws_secretsmanager_secret.smtp_password.arn
}
