# # Security group for the ec2 instance
# module "security_group" {
#   source  = "terraform-aws-modules/security-group/aws"
#   version = "~> 4.0"

#   name        = "developer-desktops-${var.env}"
#   description = "Security group for developer desktops"
#   vpc_id = local.vpc_id
#   #vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

#   #ingress_cidr_blocks = ["10.0.0.0/16"]
# #   ingress_rules       = ["all-icmp"]
#   egress_rules        = ["all-all"]
# #   ingress_with_cidr_blocks = [
# #     {
# #       from_port   = 3389
# #       to_port     = 3389
# #       protocol    = "tcp"
# #       description = "JI-RDP"
# #       cidr_blocks = "82.34.158.62/32"
# #     },
# #   ]
# }

# # Create an EC2 instance
# module "ec2" {
#   for_each = var.developers
#   source = "terraform-aws-modules/ec2-instance/aws"
#   version = "4.3.0"
#   name = "${each.value}-developer-desktop-${var.env}"
#   #key_name = aws_key_pair.developer_desktop.key_name
#   ami = var.ami
#   instance_type               = var.instance_size
#   #availability_zone           = "${var.region}b"
#   #subnet_id                   = data.aws_subnet.selected.id
#   subnet_id = local.subnet_id
#   vpc_security_group_ids      = [module.security_group.security_group_id]
#   associate_public_ip_address = false
#   iam_instance_profile = aws_iam_instance_profile.developer_desktop.name
#   #user_data = data.template_file.startup.rendered
#   monitoring = true
#   root_block_device = [
#     {
#       encrypted   = true
#       volume_type = "gp3"
#       throughput  = 200
#       volume_size = 200
#     },
#   ]
#   metadata_options = {
#        http_endpoint = "enabled"
#        http_tokens   = "required"
#   }
# }

# # data "template_file" "startup" {
# #  template = file("ssm-agent-installer.sh")
# #  vars = {
# #    gitlab_registration_token = "${var.gitlab_registration_token}"
# #    environment = "${var.env}"
# #  }
# # }

# # # Attach an ebs volume
# # resource "aws_volume_attachment" "this" {
# #   device_name = "/dev/sdh"
# #   volume_id   = aws_ebs_volume.this.id
# #   instance_id = module.ec2.id
# # }

# # # Add a KMS key for the EBS volume as Checkov requires it

# # resource "aws_kms_key" "a" {
# #   description             = "KMS key 1"
# #   deletion_window_in_days = 10
# #   enable_key_rotation = true
# # }

# # # Define the EBS volume
# # resource "aws_ebs_volume" "this" {
# #   availability_zone = data.aws_subnet.selected.availability_zone
# #   encrypted = true
# #   kms_key_id = aws_kms_key.a.arn
# #   size              = 1
# # }

# # Create an IAM instance profile
# resource "aws_iam_instance_profile" "developer_desktop" {
#   name = "developer_desktop_${var.env}"
#   role = aws_iam_role.developer_desktop.name
# }

# # Define the IAM role
# resource "aws_iam_role" "developer_desktop" {
#   name = "developer_desktop-${var.env}"
#   path = "/"
#   assume_role_policy = data.aws_iam_policy_document.developer_desktop.json
# }

# # Create policy document for STS SSM
# data "aws_iam_policy_document" "developer_desktop" {
#   statement {
#     actions = ["sts:AssumeRole"]

#     principals {
#       type        = "Service"
#       identifiers = [
#         "ssm.amazonaws.com", "ec2.amazonaws.com"
#       ]
#     }
#     }
#   }

# # Attach the policy
# resource "aws_iam_role_policy_attachment" "ssm" {
#   role       = aws_iam_role.developer_desktop.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# }

# # # Attach poweruser policy for ec2
# # resource "aws_iam_role_policy_attachment" "poweruser" {
# #   role       = aws_iam_role.developer_desktop.name
# #   policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
# # }
