module "aws-web-app-1" {
  source = "../../modules/aws-web-app"

  # Deploy conditionally based on Feature Flag variable
  count = var.deploy_aws_webapp == true ? 1 : 0

  # module attributes here
}