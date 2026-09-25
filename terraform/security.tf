resource "aws_security_group" "alb" {

  name = "${local.name}-alb-sg"

  description = "Security group for Application Load Balancer"

  vpc_id = aws_vpc.main.id


  ingress {

    description = "HTTP from Internet"

    from_port = 80

    to_port = 80

    protocol = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }


  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}
resource "aws_security_group" "ecs_instance" {

  name = "${local.name}-ecs-instance-sg"

  description = "Security group for ECS EC2 container instances"

  vpc_id = aws_vpc.main.id


  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}
resource "aws_security_group" "ecs_task" {

  name = "${local.name}-ecs-task-sg"

  description = "Security group for ECS tasks"

  vpc_id = aws_vpc.main.id


  ingress {

    description = "Application traffic from ALB"

    from_port = 3000

    to_port = 3000

    protocol = "tcp"

    security_groups = [
      aws_security_group.alb.id
    ]
  }


  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

