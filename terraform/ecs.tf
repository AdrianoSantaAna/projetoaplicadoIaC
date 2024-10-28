resource "aws_security_group" "ecs_sg" {
  name        = "ecs-sg-${var.project}-${var.environment}"
  description = "Security Group for ECS Service"
  vpc_id      = aws_vpc.anaexames.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ECS Security Group"
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = file("${path.module}/iam/task_execution_role.json")
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "dotnet-cluster"
}

resource "aws_ecs_task_definition" "dotnet_task" {
  family                   = "dotnet-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"

  container_definitions = <<DEFINITION
  [
    {
      "name": "dotnet-app",
      "image": "your-docker-repo/your-dotnet-app:latest",
      "portMappings": [
        {
          "containerPort": 443,
          "hostPort": 443
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/dotnet-app",
          "awslogs-region": "sa-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
DEFINITION

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
}

resource "aws_ecs_service" "dotnet_service" {
  name            = "dotnet-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.dotnet_task.arn
  desired_count   = 2

  network_configuration {
    subnets         = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_groups = [aws_security_group.ecs_sg.id]  # Usando o Security Group definido
    assign_public_ip = false
  }

  launch_type = "FARGATE"

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
}

resource "aws_appautoscaling_target" "ecs_scaling_target" {
  max_capacity       = 5
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.dotnet_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "scale_up" {
  name                   = "scale-up"
  resource_id            = aws_appautoscaling_target.ecs_scaling_target.resource_id
  scalable_dimension     = aws_appautoscaling_target.ecs_scaling_target.scalable_dimension
  service_namespace      = aws_appautoscaling_target.ecs_scaling_target.service_namespace
  policy_type            = "StepScaling"
  
  step_scaling_policy_configuration {
    adjustment_type        = "ChangeInCapacity"
    cooldown               = 300
  
    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_appautoscaling_policy" "scale_down" {
  name                   = "scale-down"
  resource_id            = aws_appautoscaling_target.ecs_scaling_target.resource_id
  scalable_dimension     = aws_appautoscaling_target.ecs_scaling_target.scalable_dimension
  service_namespace      = aws_appautoscaling_target.ecs_scaling_target.service_namespace
  policy_type            = "StepScaling"

  step_scaling_policy_configuration {
    adjustment_type        = "ChangeInCapacity"
    cooldown               = 300
    
    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cpu_high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    ClusterName  = aws_ecs_cluster.ecs_cluster.name
    ServiceName  = aws_ecs_service.dotnet_service.name
  }

  alarm_actions = [aws_appautoscaling_policy.scale_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "cpu_low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 20

  dimensions = {
    ClusterName  = aws_ecs_cluster.ecs_cluster.name
    ServiceName  = aws_ecs_service.dotnet_service.name
  }

  alarm_actions = [aws_appautoscaling_policy.scale_down.arn]
}


