#Application Layer
resource "aws_ecs_cluster" "main" {
  name = "${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "employee_registry" {
  family             = "${var.environment}-employee-registry"
  network_mode       = "awsvpc"
  cpu                = var.ecs_cpu
  memory             = var.ecs_memory
  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name  = "employee-registry"
    image = var.employee_registry_image
    portMappings = [
      {
        containerPort = var.container_port
        protocol      = "tcp"
        name          = "http"
      }
    ],
    environment = [
      {
        name  = "DB_HOST"
        value = aws_db_instance.postgresql.address
      }
    ],
    secrets = [
      {
        name      = "DB_USER"
        valueFrom = "${aws_secretsmanager_secret_version.employee_registry.arn}:username::"
      },
      {
        name      = "DB_PASSWORD"
        valueFrom = "${aws_secretsmanager_secret_version.employee_registry.arn}:password::"
      },
      {
        name      = "DB_NAME"
        valueFrom = "${aws_secretsmanager_secret_version.employee_registry.arn}:db_name::"
      }
    ],
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/${var.environment}-employee-registry"
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "employee-registry"
      }
    }
  }])
}

resource "aws_ecs_service" "employee_registry" {
  name            = "${var.environment}-employee-registry"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.employee_registry.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.employee_registry.arn
    container_name   = "employee-registry"
    container_port   = var.container_port
  }

  network_configuration {
    subnets          = var.private_subnets_ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  depends_on = [aws_ecs_task_definition.employee_registry]
}

resource "aws_cloudwatch_log_group" "employee_registry_logs" {
  name              = "/ecs/${var.environment}-employee-registry"
  retention_in_days = 7
}

resource "aws_appautoscaling_target" "target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.employee_registry.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.ecs_min_asg_count
  max_capacity       = var.ecs_max_asg_count
}

resource "aws_appautoscaling_policy" "up" {
  name               = "employee_registry_scale_up"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.employee_registry.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    dynamic "step_adjustment" {
      for_each = var.ecs_scale_up_steps
      content {
        metric_interval_upper_bound = step_adjustment.value.upper_bound
        metric_interval_lower_bound = step_adjustment.value.lower_bound
        scaling_adjustment          = step_adjustment.value.adjustment
      }
    }
  }
}

resource "aws_appautoscaling_policy" "down" {
  name               = "employee_registry_scale_down"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.employee_registry.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    dynamic "step_adjustment" {
      for_each = var.ecs_scale_down_steps
      content {
        metric_interval_upper_bound = step_adjustment.value.upper_bound
        metric_interval_lower_bound = step_adjustment.value.lower_bound
        scaling_adjustment          = step_adjustment.value.adjustment
      }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "service_cpu_high" {
  alarm_name          = "employee_registry_cpu_utilization_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "85"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.employee_registry.name
  }

  alarm_actions = [aws_appautoscaling_policy.up.arn]
}

resource "aws_cloudwatch_metric_alarm" "service_cpu_low" {
  alarm_name          = "employee_registry_cpu_utilization_low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.employee_registry.name
  }
  alarm_actions = [aws_appautoscaling_policy.down.arn]
}