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

variable "bucket_id" {
  type = string
  default = "s3://amartfstate/storestate/"
}

variable "bucket_arn" {
  type = string
  default = "arn:aws:s3:::amartfstate/storestate/"
}
