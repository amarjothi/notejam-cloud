// Upload Lets Encrypt Certs to ACM
resource "aws_acm_certificate" "notejampoc_online" {
  private_key = file("pk.pem")
  certificate_body = file("cert.pem")
  certificate_chain = file("chain.pem")

  lifecycle {
    create_before_destroy = true
  }
  }


// Define ECR repositories for each ECS service

resource "aws_ecr_repository" "ecs_services" {
  #checkov:skip=CKV_AWS_136: Will add KMS post PoC
  #checkov:skip=CKV_AWS_51: We want to overwrite tags at the moment
  for_each = var.ecs_services
  name                 = each.value.container_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

// Create the ECS cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-ecs-cluster-${var.env}"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

// Create the ECS services
resource "aws_ecs_service" "ecs_services" {
  for_each = var.ecs_services
  name        = each.value.container_name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.ecs_task[each.key].arn
  desired_count = each.value.desired_count
  launch_type     = "FARGATE"
  service_registries {
    registry_arn = aws_service_discovery_service.main.arn
    }

  network_configuration {
    security_groups = [module.ecs_task_sg.security_group_id]
    subnets         = [
        element(data.terraform_remote_state.vpc.outputs.private_subnets, 0),
        element(data.terraform_remote_state.vpc.outputs.private_subnets, 1)]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group[each.key].arn
    container_name   = each.value.container_name
    container_port   = each.value.container_port
  }
}

// Task definitions for each ECS service
resource "aws_ecs_task_definition" "ecs_task" {
  for_each = var.ecs_services
  requires_compatibilities = ["FARGATE"]
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn = aws_iam_role.ecs_task_role.arn
  network_mode = "awsvpc"
  cpu = each.value.cpu
  memory = each.value.memory
  family                   = each.value.container_name
  container_definitions    = jsonencode([
    {
      name                = each.value.container_name
      image               = each.value.image_identifier
      portMappings        = [
        {
          containerPort   = each.value.container_port
          hostPort        = each.value.container_port
        }
      ]
      cpu                 = each.value.cpu
      memory              = each.value.memory
      environment         = [
        {
          name            = "ASPNETCORE_ENVIRONMENT"
          value           = each.value.environment["ASPNETCORE_ENVIRONMENT"]
        },
        {
          name            = "ASPNETCORE_URLS"
          value           = each.value.environment["ASPNETCORE_URLS"]
        }
      ]
      secrets             = [
        {
          name            = "ASPNETCORE_ConnectionStrings__Default"
          valueFrom       = "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:CONNECTION_STRING"
        },
        {
          name            = "GraphApi__ClientSecret"
          valueFrom       = "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:GRAPHAPI_CLIENTSECRET"
        }
      ]
      logConfiguration    = {
        logDriver         = "awslogs"
        options           = {
          "awslogs-create-group"    = "true"
          "awslogs-group"           = "${var.project_name}-ecs-log-group-${var.env}"
          "awslogs-region"          = var.region
          "awslogs-stream-prefix"   = var.env
        }
      }
    }
  ])
}

// Add target group for each ECS service
resource "aws_lb_target_group" "target_group" {
  for_each = var.ecs_services
  name     = "${var.project_name}-ecs-${each.value.container_name}"
  port     = each.value.container_port
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.vpc.outputs.vpc_id
  target_type = "ip"


  health_check {
    path                = "/healthz/live"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# // Add listener for each ECS service to a load balancer called "prod"
resource "aws_lb_listener" "prod" {
  #checkov:skip=CKV_AWS_2: Don't need HTTPS for internal just yet
  #checkov:skip=CKV_AWS_103: "Internal load balancer"  
  for_each = var.ecs_services
  load_balancer_arn = aws_lb.ecs_service[each.key].arn
  port     = each.value.container_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group[each.key].arn
  }
}

# #   depends_on = [
# #     aws_lb_target_group.target_group,
# #     aws_lb.ecs_service
# #   ]
# # }

// Create a load balancer for each ECS Server
resource "aws_lb" "ecs_service" {
  #checkov:skip=CKV2_AWS_20: "Internal load balancer"

  #checkov:skip=CKV_AWS_131
  #checkov:skip=CKV_AWS_150: Don't need deletion protection for PoC
  #checkov:skip=CKV_AWS_91: Can add logging post PoC
  #checkov:skip=CKV_AWS_2: Don't need HTTPS for internal just yet
  for_each = var.ecs_services
  name               = "${each.value.container_name}-ecs-lb-${var.env}"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [module.lb_sg.security_group_id]
  subnets            = [
    element(data.terraform_remote_state.vpc.outputs.private_subnets, 0),
    element(data.terraform_remote_state.vpc.outputs.private_subnets, 1)]

  tags = {
    Name = "${each.value.container_name}-ecs-lb-${var.env}"
  }
}

# # resource "aws_lb" "prod" {
# #   name               = "ecs-lb-${var.env}"
# #   internal           = true
# #   load_balancer_type = "application"
# #   security_groups    = [module.lb_sg.security_group_id]
# #   subnets            = [
# #     element(data.terraform_remote_state.vpc.outputs.private_subnets, 0),
# #     element(data.terraform_remote_state.vpc.outputs.private_subnets, 1)]

# #   tags = {
# #     Name = "ecs-lb-${var.env}"
# #   }
# # }

// Create security group for load balancer
module "lb_sg" {
  source = "terraform-aws-modules/security-group/aws"
  version = "4.0.0"

  name        = "${var.project_name}-ecs-lb-sg-${var.env}"
  description = "Security group for ECS load balancer"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress_cidr_blocks = var.ecs_lb_ingress_cidr_blocks
  ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.api_gateway_sg.security_group_id
    },
    {
      rule                     = "https-443-tcp"
      source_security_group_id = module.api_gateway_sg.security_group_id
    }
  ]
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  egress_rules        = ["all-all"]
}

// Create security group for ecs_task
module "ecs_task_sg" {
  source = "terraform-aws-modules/security-group/aws"
  version = "4.0.0"

  name        = "${var.project_name}-ecs-task-sg-${var.env}"
  description = "Security group for ECS tasks"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress_cidr_blocks = var.ecs_lb_ingress_cidr_blocks
  ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.lb_sg.security_group_id
    },
    {
      rule                     = "https-443-tcp"
      source_security_group_id = module.lb_sg.security_group_id
    }
  ]
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  egress_rules        = ["all-all"]

}