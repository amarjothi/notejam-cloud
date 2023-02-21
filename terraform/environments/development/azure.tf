module "azure-web-app-1" {
  source = "../../modules/azure-web-app"

  # Deploy conditionally based on Feature Flag variable
  count = var.deploy_az_webapp == true ? 1 : 0

  # module attributes here
}
