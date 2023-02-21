backend "s3" {
       bucket = aws_s3_bucket.s3Bucket.id
       key    = aws_s3_bucket.s3Bucket.arn
       region = var.region
}


resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}