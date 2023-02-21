## global variables

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

variable project_name {
    type = string
    description = "The environment to deploy the resources to"
    default = null
}

## ec2 variables

# variable ami {
#     type = string
#     description = "The environment to deploy the resources to"
#     default = null 
# }

# variable instance_size {
#     type = string
#     description = "The environment to deploy the resources to"
#     default = null
# }

variable developers {
    type = map(string)
    description = "Map of users"
    default = {}
}

## workspaces variables
variable workspace_bundle_ids {
    type = map(string)
    description = "Workspace bundle ID to use for the workspaces"
    default = null
}

variable ad_domain {
    type = string
    description = "Name for the Active Directory domain"
    default = null
}

variable ad_password {
    type = string
    description = "Password to set for global admin on workspaces"
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
