locals {
  environment = terraform.workspace == "default" ? var.environment : terraform.workspace

  name_prefix = "${var.project_name}-${local.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = local.environment
    Workspace   = terraform.workspace
    ManagedBy   = "Terraform"
  }
}

module "networking" {
  source = "./modules/networking"

  project_name         = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "security" {
  source = "./modules/security"

  project_name   = local.name_prefix
  vpc_id         = module.networking.vpc_id
  container_port = var.container_port
}

module "iam" {
  source = "./modules/iam"

  project_name = local.name_prefix
}

module "database" {
  source = "./modules/database"

  project_name          = local.name_prefix
  vpc_id                = module.networking.vpc_id
  private_subnet_ids    = module.networking.private_subnet_ids
  rds_security_group_id = module.security.rds_security_group_id
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
  db_instance_class     = var.db_instance_class
  db_allocated_storage  = var.db_allocated_storage
  db_engine_version     = var.db_engine_version
}

module "load_balancer" {
  source = "./modules/load-balancer"

  project_name          = local.name_prefix
  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
  container_port        = var.container_port
  certificate_arn       = module.dns.certificate_arn
}

module "dns" {
  source = "./modules/dns"

  project_name = local.name_prefix
  domain_name  = var.domain_name
  alb_dns_name = module.load_balancer.alb_dns_name
  alb_zone_id  = module.load_balancer.alb_zone_id
}

module "ses" {
  source = "./modules/ses"

  project_name   = local.name_prefix
  domain_name    = var.domain_name
  hosted_zone_id = module.dns.hosted_zone_id
  admin_email    = var.admin_email
}

module "secrets" {
  source = "./modules/secrets"

  project_name  = local.name_prefix
  db_username   = var.db_username
  db_password   = var.db_password
  db_endpoint   = module.database.db_endpoint
  db_name       = var.db_name
  jwt_secret    = var.jwt_secret
  smtp_username = var.smtp_username
  smtp_password = var.smtp_password
}

module "ecs" {
  source = "./modules/ecs"

  project_name             = local.name_prefix
  aws_region               = var.aws_region
  public_subnet_ids        = module.networking.public_subnet_ids
  ecs_security_group_id    = module.security.ecs_security_group_id
  target_group_arn         = module.load_balancer.target_group_arn
  task_execution_role_arn  = module.iam.ecs_task_execution_role_arn
  task_role_arn            = module.iam.ecs_task_role_arn
  container_image          = var.container_image
  container_port           = var.container_port
  task_cpu                 = var.task_cpu
  task_memory              = var.task_memory
  desired_count            = var.desired_count
  domain_name              = var.domain_name
  database_url_secret_arn  = module.secrets.database_url_secret_arn
  jwt_secret_arn           = module.secrets.jwt_secret_arn
  smtp_username_secret_arn = module.secrets.smtp_username_secret_arn
  smtp_password_secret_arn = module.secrets.smtp_password_secret_arn
  email_noreply            = var.email_noreply
  smtp_host                = var.smtp_host
  smtp_port                = var.smtp_port
  http_listener_arn        = module.load_balancer.http_listener_arn
  https_listener_arn       = module.load_balancer.https_listener_arn
}

module "ecr" {
  source = "./modules/ecr"

  project_name = local.name_prefix
}
