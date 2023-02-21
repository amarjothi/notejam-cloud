// Allow users to administer their own passwords and MFA

resource "aws_iam_policy" "password_mgmt" {
  #checkov:skip=CKV_AWS_287: We need to allow users to change their own passwords
  #checkov:skip=CKV_AWS_286: We need to allow users to change their own passwords
  #checkov:skip=CKV_AWS_289: We need to allow users to change their own passwords
  name        = "password-mgmt"
  description = "A password change policy"
  policy      = <<-EOT
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Action": "iam:GetAccountPasswordPolicy",
                    "Resource": "*"
                },
                {
                    "Effect": "Allow",
                    "Action": "iam:ChangePassword",
                    "Resource": [
                      "arn:aws:iam::${data.aws_caller_identity.this.account_id}:user/$${aws:username}",
                      "arn:aws:iam::${data.aws_caller_identity.this.account_id}:user/*/$${aws:username}"
                      ]
                },
                {
                    "Effect": "Allow",
                    "Action": [
                        "iam:DeactivateMFADevice",
                        "iam:DeleteVirtualMFADevice",
                        "iam:EnableMFADevice",
                        "iam:ResyncMFADevice",
                        "iam:UntagMFADevice",
                        "iam:TagMFADevice",
                        "iam:CreateVirtualMFADevice",
                        "iam:ListMFADevices",
                        "iam:CreateAccessKey",
                        "iam:DeleteAccessKey",
                        "iam:GetAccessKeyLastUsed",
                        "iam:GetUser",
                        "iam:ListAccessKeys",
                        "iam:UpdateAccessKey"],
                    "Resource": "*"
                }
              ]
         }
    EOT
}