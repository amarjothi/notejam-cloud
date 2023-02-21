resource "aws_directory_service_directory" "aws-managed-ad" {
  name = var.ad_domain
  description = "${var.project_name} directory"
  password = var.ad_password
  edition = "Standard"
  type = "MicrosoftAD"  
  
  vpc_settings {
    vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
    subnet_ids = [
      data.aws_subnet.private_3.id,
      data.aws_subnet.private_2.id
      ]
  }  
  
  tags = {
    Name = "${var.project_name} AD"
    Environment = var.env
  }
}

resource "aws_vpc_dhcp_options" "dns_resolver" {
  domain_name_servers = aws_directory_service_directory.aws-managed-ad.dns_ip_addresses
  domain_name = var.ad_domain
  
  tags = {
    Name = "${var.project_name}-workspaces-dhcp-option"
    Environment = var.env
  }
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  dhcp_options_id = aws_vpc_dhcp_options.dns_resolver.id
}