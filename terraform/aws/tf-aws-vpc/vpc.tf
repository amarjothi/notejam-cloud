module "vpc" {
  #checkov:skip=CKV_AWS_111: "The VPC module is not maintained by us, so we can't fix the issue"
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19"

  name = "${var.project_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = data.aws_availability_zones.available.names
  private_subnets = ["10.0.0.0/23", "10.0.10.0/23", "10.0.20.0/23"]
  public_subnets  = ["10.0.100.0/23", "10.0.110.0/23", "10.0.120.0/23"]
  private_subnet_names = ["${var.project_name}-private-1a", "${var.project_name}-private-2b", "${var.project_name}-private-3c"]
  public_subnet_names  = ["${var.project_name}-public-1a", "${var.project_name}-public-2b", "${var.project_name}-public-3c"]

  enable_ipv6 = false

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_dedicated_network_acl   = true
  private_dedicated_network_acl  = true
  public_inbound_acl_rules       = var.network_acls["public_inbound"]
  public_outbound_acl_rules      = var.network_acls["public_outbound"]
  private_inbound_acl_rules       = var.network_acls["private_inbound"]
  private_outbound_acl_rules      = var.network_acls["private_outbound"]

  default_route_table_name = "${var.project_name}-default-route-table" 

  manage_default_security_group = true
  default_security_group_ingress = []
  default_security_group_egress = []

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60

  # default_security_group_ingress = [
  #   {
  #     from_port = 0
  #     to_port   = 0
  #     protocol  = "-1"
  #     self = true
  #   }
  # ]
  # default_security_group_egress = [
  #  {
  #   to_port = 0
  #   from_port = 0
  #   protocol = "-1"
  #   self = true
  # }
  # ]
  default_security_group_name = "${var.project_name}-sg-default"
  default_security_group_tags= { 
    Name = "${var.project_name}-sg-default"
  }

  map_public_ip_on_launch = false

  # Define the tags for the various VPC components
  # public_subnet_tags = {
  #   Name = "${var.project_name}-public-subnet"
  # }
  # private_subnet_tags = {
  #   Name = "${var.project_name}-private-subnet"
  # }
  vpc_tags = {
    Name = "${var.project_name}-vpc"
  }
  igw_tags = {
    Name = "${var.project_name}-igw"
  }
  nat_eip_tags = {
    Name = "${var.project_name}-nat-eip"
  }
  nat_gateway_tags = {
    Name = "${var.project_name}-nat-gateway"
  }
  private_acl_tags = {
    Name = "${var.project_name}-private-acl"
  }
  public_acl_tags = {
    Name = "${var.project_name}-public-acl"
  }
  private_route_table_tags = {
    Name = "${var.project_name}-private-route-table"
  }

  public_route_table_tags = {
    Name = "${var.project_name}-public-route-table"
    DeployMethod = "Terraform"
  }
  default_route_table_tags = {
    Name = "${var.project_name}-default-route-table"
    DeployMethod = "Terraform"
  }
}

module "endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "3.19"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [data.aws_security_group.default.id]

  endpoints = {
    s3 = {
      # interface endpoint
      service             = "s3"
      tags                = { Name = "${var.project_name}_s3-vpc-endpoint" }
      subnet_ids          = module.vpc.private_subnets
    },
    kms = {
      service             = "kms"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      tags                = { Name = "${var.project_name}_kms-vpc-endpoint" }
  },
    athena = {
      service             = "athena"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      tags                = { Name = "${var.project_name}_athena-vpc-endpoint" }
  },
    clouddirectory = {
      service             = "clouddirectory"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      tags                = { Name = "${var.project_name}_clouddirectory-vpc-endpoint" }
  },
    glue = {
      service             = "glue"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      tags                = { Name = "${var.project_name}_glue-vpc-endpoint" }
  },
    workspaces = {
      service             = "workspaces"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      tags                = { Name = "${var.project_name}_workspaces-vpc-endpoint" }
  }
}
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}

# ## Default VPC
# resource "aws_default_vpc" "default" {
#   tags = {
#     Name = "Default VPC"
#     Createdby = "AWS"
#     ManagedBy = "Terraform"
#   }
# }

# resource "aws_default_security_group" "default" {
#   vpc_id = aws_default_vpc.default.id

#   tags = {
#     Name = "Default Security Group"
#     Createdby = "AWS"
#     ManagedBy = "Terraform"
#   }
# }