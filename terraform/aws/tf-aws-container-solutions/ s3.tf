# #Create S3 bucket for storing the data for Claims Hub
# module "s3_email_storage" {
#   #checkov:skip=CKV_AWS_144: Don't need cross region relication for PoC
#   source = "terraform-aws-modules/s3-bucket/aws"
#   version = "3.6.1"
#   bucket = "${var.project_name}-email-storage-${var.env}"
#   acl    = "private"

#   # attach_deny_insecure_transport_policy = true
#   # attach_require_latest_tls_policy      = true

#   block_public_acls = true
#   block_public_policy = true
#   ignore_public_acls = true
#   restrict_public_buckets = true

#   server_side_encryption_configuration = {
#     rule = {
#       apply_server_side_encryption_by_default = {
#         kms_master_key_id = aws_kms_key.objects.arn
#         sse_algorithm     = "aws:kms"
#       }
#     }
#   }

#   logging = {
#     target_bucket = module.log_bucket.s3_bucket_id
#     target_prefix = "${var.project_name}-s3-bucket-logs-${var.env}-log/"
#   }

#   versioning = {
#     status     = true
#     mfa_delete = false
#   }

#   # Wouldn't recommend setting this usually as it deletes all info from the bucket, however, enabling for demo purposes.
#   force_destroy = true

#   tags = {
#     Name = "${var.project_name}-email-storage-${var.env}"
#   }
# }


# module "log_bucket" {
#   #checkov:skip=CKV_AWS_144: Don't need cross region relication for PoC
#   source = "terraform-aws-modules/s3-bucket/aws"
#   version = "3.3.0"
#   bucket        = "${var.project_name}-s3-bucket-logs-${var.env}"
#   acl           = "log-delivery-write"
#   force_destroy = true
#   attach_deny_insecure_transport_policy = true
#   attach_require_latest_tls_policy      = true

#   block_public_acls = true
#   block_public_policy = true
#   ignore_public_acls = true
#   restrict_public_buckets = true

#   server_side_encryption_configuration = {
#     rule = {
#       apply_server_side_encryption_by_default = {
#         kms_master_key_id = aws_kms_key.objects.arn
#         sse_algorithm     = "aws:kms"
#       }
#     }
#   }

#     tags = {
#     Name = "${var.project_name}-bucket-logs-${var.env}"
#   }

# }

# resource "aws_kms_key" "objects" {
#   description             = "${var.project_name}-${var.env} - KMS key is used to encrypt bucket objects"
#   deletion_window_in_days = 7
#   policy = data.aws_iam_policy_document.default_kms_policy.json
#   tags = {
#     Name = "${var.project_name}-${var.env}-s3-kms-key"
#   }
# }

# data "aws_iam_policy_document" "default_kms_policy" {
# #checkov:skip=CKV_AWS_111: Ensure IAM policies does not allow write access without constraints - Fix post PoC
# #checkov:skip=CKV_AWS_109: Ensure IAM policies does not allow permissions management / resource exposure without constraints: Fix post PoC
#   statement {
#     actions = [
#                 "kms:GenerateDataKey",
#                 "kms:Decrypt"
#                 ]

#     principals {
#       type        = "Service"
#       identifiers = ["s3.amazonaws.com"]
#     }

#     resources = [module.s3_email_storage.s3_bucket_arn, module.log_bucket.s3_bucket_arn]
#     }

#   statement {
#     actions = ["kms:*"]
#     principals {
#       type        = "AWS"
#       identifiers = [
#       "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
#       ]
#     }
#     resources = ["*"]
#   }
# }