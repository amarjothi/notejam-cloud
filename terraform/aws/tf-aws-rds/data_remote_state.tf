data "terraform_remote_state" "vpc" {
  backend = "http"

  config = {
    address = var.vpc_remote_state_address
    username = var.gitlab_username
    password = var.gitlab_access_token
  }
}

data "terraform_remote_state" "workspaces" {
  backend = "http"

  config = {
    address = var.workspaces_remote_state_address
    username = var.gitlab_username
    password = var.gitlab_access_token
  }
}