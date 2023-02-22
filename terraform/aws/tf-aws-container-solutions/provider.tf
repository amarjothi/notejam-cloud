terraform {
    backend "http" {}

required_version = ">= 1.0"

required_providers {
  aws = {
    source = "hashicorp/aws"
    version = ">= 4.51.0"
    }
  }
}

provider "aws" {
  region = var.region
    default_tags {
      tags = {
        Project = "notejampoc"
        DeployMethod = "Terraform"
        Environment = var.env
    }
  }
}

provider "aws" {
  alias = "ireland"
  region = "eu-west-1"
    default_tags {
      tags = {
        Project = "notejampoc"
        DeployMethod = "Terraform"
        Environment = var.env
    }
  }
}

