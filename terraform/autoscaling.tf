resource "aws_launch_template" "ecs" {

  name_prefix = "${local.name}-ecs-"

  image_id = data.aws_ssm_parameter.ecs_ami.value

  instance_type = var.ecs_instance_type


  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance.name
  }


  vpc_security_group_ids = [
    aws_security_group.ecs_instance.id
  ]


  metadata_options {

    http_endpoint = "enabled"

    http_tokens = "required"

    http_put_response_hop_limit = 1
  }


  monitoring {
    enabled = true
  }


  user_data = base64encode(<<-EOF
    #!/bin/bash

    echo "ECS_CLUSTER=${aws_ecs_cluster.main.name}" >> /etc/ecs/ecs.config

    echo "ECS_ENABLE_CONTAINER_METADATA=true" >> /etc/ecs/ecs.config

    echo "ECS_AWSVPC_BLOCK_IMDS=true" >> /etc/ecs/ecs.config

    echo "ECS_DISABLE_PRIVILEGED=true" >> /etc/ecs/ecs.config
  EOF
  )


  tag_specifications {

    resource_type = "instance"

    tags = {
      Name = "${local.name}-ecs-instance"
    }
  }
}
resource "aws_autoscaling_group" "ecs" {

  name = "${local.name}-ecs-asg"

  min_size = var.ecs_min_instances

  desired_capacity = var.ecs_desired_instances

  max_size = var.ecs_max_instances


  vpc_zone_identifier = aws_subnet.private[*].id


  protect_from_scale_in = true


  launch_template {

    id = aws_launch_template.ecs.id

    version = "$Latest"
  }


  tag {

    key = "Name"

    value = "${local.name}-ecs-instance"

    propagate_at_launch = true
  }


  tag {

    key = "AmazonECSManaged"

    value = "true"

    propagate_at_launch = true
  }


  lifecycle {

    ignore_changes = [
      desired_capacity
    ]
  }
}
resource "aws_ecs_capacity_provider" "ec2" {

  name = "${local.name}-cp"


  auto_scaling_group_provider {

    auto_scaling_group_arn = aws_autoscaling_group.ecs.arn


    managed_scaling {

      status = "ENABLED"

      target_capacity = 80

      minimum_scaling_step_size = 1

      maximum_scaling_step_size = 2

      instance_warmup_period = 300
    }


    managed_termination_protection = "ENABLED"

    managed_draining = "ENABLED"
  }
}
resource "aws_ecs_cluster_capacity_providers" "main" {

  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = [
    aws_ecs_capacity_provider.ec2.name
  ]


  default_capacity_provider_strategy {

    capacity_provider = aws_ecs_capacity_provider.ec2.name

    base = 1

    weight = 100
  }
}

