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

variable aws_users {
    type = map(string)
    description = "AWS users"
    default = null
}

variable aws_service_users {
    type = map(string)
    description = "AWS users"
    default = null
}

variable aws_users_admin {
    type = list(string)
    description = "AWS users to add to the Admin group"
    default = null
}

variable aws_users_poweruser {
    type = list(string)
    description = "AWS users to add to the Poweruser group"
    default = null
}