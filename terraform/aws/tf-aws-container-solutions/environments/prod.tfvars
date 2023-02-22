project_name = "notejampoc"
domain_name = "notejampoc.online"

gitlab_username = "gitlab-ci-token"


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
      image_identifier = ""
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
 
}