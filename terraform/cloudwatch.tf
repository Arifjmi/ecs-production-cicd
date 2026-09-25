resource "aws_cloudwatch_log_group" "ecs" {

  name = "/ecs/${local.name}"

  retention_in_days = 30
}

