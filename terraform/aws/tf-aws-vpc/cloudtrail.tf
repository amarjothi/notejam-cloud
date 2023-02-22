resource "aws_cloudtrail" "cloudtrail" {
  #checkov:skip=CKV_AWS_252:Don't want to notify people at the moment
  #checkov:skip=CKV_AWS_35:KMS to be implemented post PoC
  name                          = "${var.project_name}-cloudtrail-${var.env}"
  s3_bucket_name                = module.s3_cloudtrail.s3_bucket_id
  s3_key_prefix                 = "cloudtrail"
  include_global_service_events = true
  enable_log_file_validation    = true
  is_multi_region_trail = true
  #cloud_watch_logs_group_arn = aws_cloudwatch_log_group.cloudtrail.arn

  depends_on = [
    module.s3_cloudtrail,
    aws_s3_bucket_policy.cloudtrail
  ]
}

// Create log group for cloudtrail
resource "aws_cloudwatch_log_group" "cloudtrail" {
  #checkov:skip=CKV_AWS_158:KMS to be implemented post PoC
  name = "${var.project_name}-cloudtrail-${var.env}"
  retention_in_days = 30
}
module "s3_cloudtrail" {
  #checkov:skip=CKV_AWS_144:Don't want multi-region replication for a PoC
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "3.3.0"
  bucket = "${var.project_name}-cloudtrail-${var.env}"
  acl    = "log-delivery-write"

#   attach_deny_insecure_transport_policy = true
#   attach_require_latest_tls_policy      = true

  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "AES256"
      }
    }
  }

  versioning = {
    status     = true
    mfa_delete = false
  }

  # Wouldn't recommend setting this usually as it deletes all info from the bucket, however, enabling for demo purposes.
  force_destroy = true

  tags = {
    Name = "${var.project_name}-cloudtrail-${var.env}"
    Environment = var.env
  }
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = module.s3_cloudtrail.s3_bucket_id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "${module.s3_cloudtrail.s3_bucket_arn}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "${module.s3_cloudtrail.s3_bucket_arn}/cloudtrail/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}