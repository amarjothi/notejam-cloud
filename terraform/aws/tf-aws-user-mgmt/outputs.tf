# Admin users
output "iam_user_arns" {
  description = "The arns"
  value       = { for k, v in module.aws_users : k => v.iam_user_arn }
}

output "iam_user_names" {
  description = "The usernames"
  value       = { for k, v in module.aws_users : k => v.iam_user_name }
}

output "keybase_password_decrypt_command" {
  description = "To decrypt the password"
  value       = { for k, v in module.aws_users : k => v.keybase_password_decrypt_command }
}

output "iam_access_key_id" {
  description = "To decrypt the password"
  value       = { for k, v in module.aws_users : k => v.iam_access_key_id }
}

output "keybase_secret_key_decrypt_command" {
  description = "To decrypt the password"
  value       = { for k, v in module.aws_users : k => v.keybase_secret_key_decrypt_command }
}

output "service_users___iam_access_key_id" {
  description = "To decrypt the password"
  value       = { for k, v in module.aws_service_users : k => v.iam_access_key_id }
}

output "service_users___keybase_secret_key_decrypt_command" {
  description = "To decrypt the password"
  value       = { for k, v in module.aws_service_users : k => v.keybase_secret_key_decrypt_command }
}

output "aws_account_number" {
  description = "The AWS account number"
  value       = data.aws_caller_identity.this.account_id
}

output "aws_signin_url" {
  description = "The AWS account number"
  value       = "https://${data.aws_caller_identity.this.account_id}.signin.aws.amazon.com/console"
}