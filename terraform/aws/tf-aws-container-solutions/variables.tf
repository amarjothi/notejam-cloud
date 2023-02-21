variable project_name {
    type = string
    description = "The name of the project."
    default = null
}

variable region {
    type = string
    description = "The AWS region to deploy the resources in to."
    default = "eu-west-2" # London
}

variable env {
    type = string
    description = "The environment to deploy the resources to"
    default = null
}

# Data remote state for Gitlab Managed Terraform state
variable "vpc_remote_state_address" {
  type = string
  description = "Gitlab remote state file address"
}

variable "gitlab_username" {
  type = string
  description = "Gitlab username to query remote state"
}

variable "gitlab_access_token" {
  type = string
  description = "GitLab access token to query remote state"
}

# // Add variables required for the certificate

# variable cert_certificate_body {
#   type = string
#   description = "The certificate body"
#   default = null
# }

# variable cert_private_key {
#   type = string
#   description = "value of the private key"
#   default = null
# }

variable "api_gateway_sg_allowlist" {
  type = list(string)
  description = "The CIDR blocks to allowlist for the API Gateway security group."
  default = []
}

variable "domain_name" {
  type = string
  description = "The domain name for the API Gateway."
  default = null
}

variable "ecs_services" {
  type = map(object({
    image_identifier = string
    container_port   = number
    container_name   = string
    cpu              = number
    memory           = number
    desired_count    = number
    environment      = map(string)
  }))
  default = null
}

variable ecs_lb_ingress_cidr_blocks {
  type = list(string)
  description = "The CIDR blocks to allowlist for the load balancer."
  default = []
}

