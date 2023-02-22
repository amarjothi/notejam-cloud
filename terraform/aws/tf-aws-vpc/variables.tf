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
    description = "The name of the project"
    default = "notejampoc"
}

variable network_acls {
    type = map(list(map(string)))
    description = "The network ACLs for the VPC"
}