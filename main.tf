provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_ecs_cluster" "main" {
  name = "it4200-aws-cluster"
}

resource "aws_ecs_task_definition" "app" {
  family                   = "it4200-api-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "arn:aws:iam::654654480835:role/LabRole"

  container_definitions = jsonencode([{
    name      = "it4200-api"
    image     = "bubbaj/it4200-fall-2026:latest"
    essential = true
    portMappings = [{
      containerPort = 8000
      hostPort      = 8000
    }]
  }])
}

resource "aws_lb" "main" {
  name               = "it4200-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
}

output "alb_dns_name" {
  value = aws_lb.main.dns_name
}
