output "vpc_id" {
  value = aws_vpc.main.id
}


output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}


output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}


output "ecs_service_name" {
  value = aws_ecs_service.app.name
}


output "ecs_capacity_provider" {
  value = aws_ecs_capacity_provider.ec2.name
}


output "ecs_task_security_group_id" {
  value = aws_security_group.ecs_task.id
}


output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}


output "target_group_arn" {
  value = aws_lb_target_group.app.arn
}


output "alb_dns_name" {
  value = aws_lb.main.dns_name
}


output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}


output "ecs_task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution.arn
}

