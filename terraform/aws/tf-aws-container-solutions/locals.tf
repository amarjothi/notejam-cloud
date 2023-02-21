locals {
  raw_data=jsondecode(file("${path.module}/etc/allow_list.txt"))
  azure_allow_list=local.raw_data.properties[*].addressPrefixes
  merged_list = concat(local.azure_allow_list,var.api_gateway_sg_allowlist)
}