// Set up the assumable role policy for read only
module "iam_group_with_assumable_roles_policy_readonly" {
  source = "terraform-aws-modules/iam/aws//modules/iam-group-with-assumable-roles-policy"
  version = "5.2.0"

  name = "readonly"
  assumable_roles = [module.iam_assumable_roles_base.readonly_iam_role_arn]
  group_users = [for v in module.aws_users : v.iam_user_name]
}

// Set up the assumable role policy for power user
module "iam_group_with_assumable_roles_policy_poweruser" {
  source = "terraform-aws-modules/iam/aws//modules/iam-group-with-assumable-roles-policy"
  version = "5.2.0"

  name = "poweruser"
  assumable_roles = [module.iam_assumable_roles_base.poweruser_iam_role_arn]
  group_users = var.aws_users_poweruser
}

// Set up assumeable role policy for admin
module "iam_group_with_assumable_roles_admin" {
  source = "terraform-aws-modules/iam/aws//modules/iam-group-with-assumable-roles-policy"
  version = "5.2.0"

  name = "admin"
  assumable_roles = [module.iam_assumable_roles_base.admin_iam_role_arn]
  group_users = var.aws_users_admin
}
