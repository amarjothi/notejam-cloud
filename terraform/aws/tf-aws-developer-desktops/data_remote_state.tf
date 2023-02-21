data "terraform_remote_state" "vpc" {
  backend = "http"

  config = {
    address = var.vpc_remote_state_address
    username = var.gitlab_username
    password = var.gitlab_access_token
  }
}

# Comment this out as not currently used
# data "aws_subnet" "private_1" {
#   id = element(data.terraform_remote_state.vpc.outputs.private_subnets, 0)
# }

data "aws_subnet" "private_2" {
  id = element(data.terraform_remote_state.vpc.outputs.private_subnets, 0)
}

data "aws_subnet" "private_3" {
  id = element(data.terraform_remote_state.vpc.outputs.private_subnets, 1)
}
