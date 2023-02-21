project_name = "cms5poc"
domain_name = "cms5poc.online"

gitlab_username = "gitlab-ci-token"
vpc_remote_state_address = "https://gitlab.com/api/v4/projects/42886287/terraform/state/tf-aws-vpc-prod"


// Define what is allowed in to the API Gateway exposed to the internet
api_gateway_sg_allowlist = [
    "82.34.158.62/32",
    "86.30.200.100/32",
    "86.137.23.203/32"
]

// Define what is allowed in to the INTERNAl load balancers
ecs_lb_ingress_cidr_blocks = [
    "10.0.0.0/23",
    "10.0.10.0/23",
    "10.0.20.0/23"
]

// Define the ECS services
ecs_services = {
    "tasks-api" = {
      image_identifier = "266146780983.dkr.ecr.eu-west-2.amazonaws.com/tasks-api:latest"
      container_port   = 80
      container_name   = "tasks-api"
      cpu              = 256
      memory           = 512
      desired_count    = 1
      environment      = {
        ASPNETCORE_ENVIRONMENT = "Staging"
        ASPNETCORE_URLS        = "http://+:80"
      }
    }

    "tasks-scheduler" = {
      image_identifier = "266146780983.dkr.ecr.eu-west-2.amazonaws.com/tasks-scheduler:latest"
      container_port   = 80
      container_name   = "tasks-scheduler"
      cpu              = 256
      memory           = 512
      desired_count    = 1
      environment      = {
        ASPNETCORE_ENVIRONMENT = "Staging"
        ASPNETCORE_URLS        = "http://+:80"
      }
    }

    "tasks-subscriber" = {
      image_identifier = "266146780983.dkr.ecr.eu-west-2.amazonaws.com/tasks-subscriber:latest"
      container_port   = 80
      container_name   = "tasks-subscriber"
      cpu              = 256
      memory           = 512
      desired_count    = 1
      environment      = {
        ASPNETCORE_ENVIRONMENT = "Staging"
        ASPNETCORE_URLS        = "http://+:80"
      }
    }
}