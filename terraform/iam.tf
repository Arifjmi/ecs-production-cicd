data "aws_iam_policy_document" "ecs_task_execution_assume" {

  statement {

    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}


resource "aws_iam_role" "ecs_task_execution" {

  name = "${local.name}-task-execution-role"

  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_assume.json
}


resource "aws_iam_role_policy_attachment" "ecs_task_execution" {

  role = aws_iam_role.ecs_task_execution.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
data "aws_iam_policy_document" "ecs_instance_assume" {

  statement {

    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "ec2.amazonaws.com"
      ]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}


resource "aws_iam_role" "ecs_instance" {

  name = "${local.name}-ecs-instance-role"

  assume_role_policy = data.aws_iam_policy_document.ecs_instance_assume.json
}


resource "aws_iam_role_policy_attachment" "ecs_instance" {

  role = aws_iam_role.ecs_instance.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}


resource "aws_iam_role_policy_attachment" "ecs_instance_ssm" {

  role = aws_iam_role.ecs_instance.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_instance_profile" "ecs_instance" {

  name = "${local.name}-ecs-instance-profile"

  role = aws_iam_role.ecs_instance.name
}

