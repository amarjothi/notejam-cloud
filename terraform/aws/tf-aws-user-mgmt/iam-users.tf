// Create users in the account (console access)
module "aws_users" {
  for_each = var.aws_users
  source   = "./modules/iam-user"
  name          = each.value
  path          = "/"
  force_destroy = true
  pgp_key       = "keybase:amarmani"
  #password_reset_required       = true
  create_iam_user_login_profile = true
  create_iam_access_key         = false
  password_length               = 16
  tags = {
    Name = each.value
    Environment = var.env
  }
}

// Create service users in the account (no MFA, no console access)
module "aws_service_users" {
  for_each = var.aws_service_users
  source   = "./modules/iam-user"
  name          = each.value
  path          = "/"
  force_destroy = true
  pgp_key       = "keybase:jamesirvine"
  #password_reset_required       = true
  create_iam_user_login_profile = false
  create_iam_access_key         = true
  password_length               = 16
  tags = {
    Name = each.value
    Environment = var.env
  }
}

// Add IAM Group for password and MFA management and add all users to it
module "iam_group_with_custom_policies_password_mgmt" {
  source = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"
  version = "5.2.0"
  name = "password_mgmt"

  group_users = [ for v in module.aws_users : v.iam_user_name ]

  custom_group_policy_arns = [
    aws_iam_policy.password_mgmt.arn
  ]
}