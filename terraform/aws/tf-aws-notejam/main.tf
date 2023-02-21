

module "aws-eks" {
  source = "./eks"
}

module "aws-aurora" {
  source = "./aurora"
}
