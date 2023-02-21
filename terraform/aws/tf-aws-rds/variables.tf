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

variable "workspaces_remote_state_address" {
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

// RDS Variables
variable rds_dbname {
    description = "The name of the database to create"
    type = string
    default = "testdb"
}

variable rds_username {
    description = "The username to create for the database"
    type = string
    default = "testuser"
}

variable rds_password {
    description = "The password to create for the database"
    type = string
    sensitive = true
    default = null
}