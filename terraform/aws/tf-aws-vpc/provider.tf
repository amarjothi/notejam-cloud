

terraform{

backend "s3" {
       bucket = "amartfstate"
       key    = "arn:aws:s3:::amartfstate/storestate/"
       region = "eu-west-2"
}

required_version = ">= 1.0"

required_providers {
  aws = {
    source = "hashicorp/aws"
   //version = ">= 4.51.0"
    }
  }
}

provider "aws" {
  region = var.region
    default_tags {
      tags = {
        Project = "cms5poc"
        DeployMethod = "Terraform"
        Environment = var.env
    }
  }
}

