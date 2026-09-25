variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "project_name" {
  type    = string
  default = "production-ecs-cicd"
}

variable "vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "github_org" {
  type = string
}

variable "github_repo" {
  type = string
}

variable "ecs_instance_type" {
  type    = string
  default = "t3.small"
}

variable "ecs_min_instances" {
  type    = number
  default = 2
}

variable "ecs_desired_instances" {
  type    = number
  default = 2
}

variable "ecs_max_instances" {
  type    = number
  default = 4
}

