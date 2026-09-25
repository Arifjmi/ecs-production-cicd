resource "aws_ecs_cluster" "main" {

  name = local.name

  setting {
    name  = "containerInsights"
    value = "enhanced"
  }
}
data "aws_ssm_parameter" "ecs_ami" {

  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id"
}
resource "aws_ecs_task_definition" "app" {

  family = local.name

  network_mode = "awsvpc"

  requires_compatibilities = [
    "EC2"
  ]

  cpu = "256"

  memory = "512"

  execution_role_arn = aws_iam_role.ecs_task_execution.arn


  container_definitions = jsonencode([

    {

      name = "app"

      image = "${aws_ecr_repository.app.repository_url}:bootstrap"

      essential = true

      cpu = 256

      memory = 512

      user = "node"

      readonlyRootFilesystem = true


      portMappings = [
        {
          containerPort = 3000
          protocol      = "tcp"
        }
      ]


      healthCheck = {

        command = [
          "CMD-SHELL",
          "wget --no-verbose --tries=1 --spider http://127.0.0.1:3000/health || exit 1"
        ]

        interval = 30

        timeout = 5

        retries = 3

        startPeriod = 10
      }


      logConfiguration = {

        logDriver = "awslogs"

        options = {

          awslogs-group = aws_cloudwatch_log_group.ecs.name

          awslogs-region = var.aws_region

          awslogs-stream-prefix = "app"
        }
      }
    }
  ])
}
resource "aws_ecs_service" "app" {

  name = "${local.name}-service"

  cluster = aws_ecs_cluster.main.id

  task_definition = aws_ecs_task_definition.app.arn

  desired_count = 0


  capacity_provider_strategy {

    capacity_provider = aws_ecs_capacity_provider.ec2.name

    base = 1

    weight = 100
  }


  deployment_minimum_healthy_percent = 100

  deployment_maximum_percent = 200


  health_check_grace_period_seconds = 60


  deployment_circuit_breaker {

    enable = true

    rollback = true
  }


  enable_ecs_managed_tags = true

  propagate_tags = "SERVICE"


  load_balancer {

    target_group_arn = aws_lb_target_group.app.arn

    container_name = "app"

    container_port = 3000
  }


  network_configuration {

    subnets = aws_subnet.private[*].id

    security_groups = [
      aws_security_group.ecs_task.id
    ]

    assign_public_ip = false
  }


  depends_on = [
    aws_ecs_cluster_capacity_providers.main,
    aws_lb_listener.http
  ]


  lifecycle {

    ignore_changes = [
      desired_count,
      task_definition
    ]
  }
}
resource "aws_appautoscaling_target" "ecs" {

  max_capacity = 6

  min_capacity = 2

  resource_id = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.app.name}"

  scalable_dimension = "ecs:service:DesiredCount"

  service_namespace = "ecs"
}
resource "aws_appautoscaling_policy" "ecs_cpu" {

  name = "${local.name}-cpu-scaling"

  policy_type = "TargetTrackingScaling"

  resource_id = aws_appautoscaling_target.ecs.resource_id

  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension

  service_namespace = aws_appautoscaling_target.ecs.service_namespace


  target_tracking_scaling_policy_configuration {

    target_value = 60

    predefined_metric_specification {

      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    scale_out_cooldown = 60

    scale_in_cooldown = 180
  }
}
resource "aws_appautoscaling_policy" "ecs_memory" {

  name = "${local.name}-memory-scaling"

  policy_type = "TargetTrackingScaling"

  resource_id = aws_appautoscaling_target.ecs.resource_id

  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension

  service_namespace = aws_appautoscaling_target.ecs.service_namespace


  target_tracking_scaling_policy_configuration {

    target_value = 70

    predefined_metric_specification {

      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    scale_out_cooldown = 60

    scale_in_cooldown = 180
  }
}

