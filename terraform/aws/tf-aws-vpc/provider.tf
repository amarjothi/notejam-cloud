

terraform{

backend "s3" {
       bucket = "amartfstate"
       key    = "arn:aws:s3:::amartfstate/storestate/"
       region = "eu-west-2"
}

required_version = ">=0.12, <0.14"

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

