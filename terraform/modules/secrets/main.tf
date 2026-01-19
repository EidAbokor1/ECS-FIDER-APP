resource "aws_secretsmanager_secret" "database_url" {
  name        = "fider/database-url"
  description = "Database connection string for Fider"
  
  tags = {
    Name = "${var.project_name}-database-url"
  }
}

resource "aws_secretsmanager_secret_version" "database_url" {
  secret_id     = aws_secretsmanager_secret.database_url.id
  secret_string = "postgres://${var.db_username}:${var.db_password}@${var.db_endpoint}/${var.db_name}?sslmode=require"
}

resource "aws_secretsmanager_secret" "jwt_secret" {
  name        = "fider/jwt-secret"
  description = "JWT signing secret for Fider"
  
  tags = {
    Name = "${var.project_name}-jwt-secret"
  }
}

resource "aws_secretsmanager_secret_version" "jwt_secret" {
  secret_id     = aws_secretsmanager_secret.jwt_secret.id
  secret_string = var.jwt_secret
}

resource "aws_secretsmanager_secret" "smtp_username" {
  name        = "fider/smtp-username"
  description = "SMTP username for email sending"
  
  tags = {
    Name = "${var.project_name}-smtp-username"
  }
}

resource "aws_secretsmanager_secret_version" "smtp_username" {
  secret_id     = aws_secretsmanager_secret.smtp_username.id
  secret_string = var.smtp_username
}

resource "aws_secretsmanager_secret" "smtp_password" {
  name        = "fider/smtp-password"
  description = "SMTP password for email sending"
  
  tags = {
    Name = "${var.project_name}-smtp-password"
  }
}

resource "aws_secretsmanager_secret_version" "smtp_password" {
  secret_id     = aws_secretsmanager_secret.smtp_password.id
  secret_string = var.smtp_password
}
