// Create assumable roles
module "iam_assumable_roles_base" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-roles"
  version = "5.2.0"
  trusted_role_arns = [
    "arn:aws:iam::${data.aws_caller_identity.this.account_id}:root"
  ]

  create_admin_role          = true
  create_poweruser_role      = true
  create_readonly_role       = true
  readonly_role_requires_mfa = true
}