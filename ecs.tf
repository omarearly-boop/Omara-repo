# --- ECS Cluster and Service ---

# ECS Cluster
resource "aws_ecs_cluster" "wikijs" {
  name = "${var.project_name}-cluster"
}

# Log Group for ECS Tasks
resource "aws_cloudwatch_log_group" "wikijs" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 7
}

# ECS Task Definition
resource "aws_ecs_task_definition" "wikijs" {
  family                   = "${var.project_name}-task"
  cpu                      = "1024" # 1 vCPU
  memory                   = "2048" # 2 GB
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "wikijs"
      image     = "ghcr.io/requarks/wiki:2" # Latest stable Wiki.js image
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      environment = [
        {
          name  = "DB_TYPE"
          value = "postgres"
        },
        {
          name  = "DB_HOST"
          value = aws_rds_cluster.wikijs.endpoint
        },
        {
          name  = "DB_PORT"
          value = "5432"
        },
        {
          name  = "DB_USER"
          value = var.db_username
        },
        {
          name  = "DB_PASS"
          value = var.db_password
        },
        {
          name  = "DB_NAME"
          value = "wikijs"
        },
        # S3 Storage Configuration
        {
          name  = "STORAGE_TYPE"
          value = "s3"
        },
        {
          name  = "STORAGE_S3_BUCKET"
          value = aws_s3_bucket.storage.id
        },
        {
          name  = "STORAGE_S3_REGION"
          value = var.aws_region
        },
        # The task role grants access, so no explicit key/secret is needed
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.wikijs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "wikijs"
        }
      }
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "wikijs" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.wikijs.id
  task_definition = aws_ecs_task_definition.wikijs.arn
  desired_count   = var.desired_ecs_tasks
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [for s in aws_subnet.private : s.id]
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.wikijs.arn
    container_name   = "wikijs"
    container_port   = 3000
  }

  # Ensure the ALB and Target Group are created before the service
  depends_on = [
    aws_lb_listener.https,
    aws_iam_role_policy_attachment.s3_access_attachment
  ]
}
