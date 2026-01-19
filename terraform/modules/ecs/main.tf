resource "aws_cloudwatch_log_group" "main" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 7
  
  tags = {
    Name = "${var.project_name}-logs"
  }
}

resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"
  
  setting {
    name  = "containerInsights"
    value = "disabled"
  }
  
  tags = {
    Name = "${var.project_name}-cluster"
  }
}

resource "aws_ecs_task_definition" "main" {
  family                   = "${var.project_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = var.task_execution_role_arn
  task_role_arn            = var.task_role_arn
  
  container_definitions = jsonencode([
    {
      name      = var.project_name
      image     = var.container_image
      essential = true
      
      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]
      
      environment = [
        {
          name  = "BASE_URL"
          value = "https://${var.domain_name}"
        },
        {
          name  = "GO_ENV"
          value = "production"
        },
        {
          name  = "LOG_LEVEL"
          value = "INFO"
        },
        {
          name  = "LOG_CONSOLE"
          value = "true"
        },
        {
          name  = "EMAIL_NOREPLY"
          value = var.email_noreply
        },
        {
          name  = "EMAIL_SMTP_HOST"
          value = var.smtp_host
        },
        {
          name  = "EMAIL_SMTP_PORT"
          value = var.smtp_port
        }
      ]
      
      secrets = [
        {
          name      = "DATABASE_URL"
          valueFrom = var.database_url_secret_arn
        },
        {
          name      = "JWT_SECRET"
          valueFrom = var.jwt_secret_arn
        },
        {
          name      = "EMAIL_SMTP_USERNAME"
          valueFrom = var.smtp_username_secret_arn
        },
        {
          name      = "EMAIL_SMTP_PASSWORD"
          valueFrom = var.smtp_password_secret_arn
        }
      ]
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.main.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = var.project_name
        }
      }
      
      healthCheck = {
        command     = ["CMD-SHELL", "./fider ping || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])
  
  tags = {
    Name = "${var.project_name}-task"
  }
}

resource "aws_ecs_service" "main" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"
  force_new_deployment = true
  
  network_configuration {
    subnets          = var.public_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = true
  }
  
  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.project_name
    container_port   = var.container_port
  }
  
  health_check_grace_period_seconds = 120
  
  depends_on = [
    var.http_listener_arn,
    var.https_listener_arn
  ]
  
  tags = {
    Name = "${var.project_name}-service"
  }
}
