terraform {
  backend "s3" {
    bucket       = "ecs-production-tfstate-498245874320"
    key          = "production/ecs/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}

