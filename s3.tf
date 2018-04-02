resource "aws_s3_bucket" "env" {
  bucket_prefix = "${var.env}-"
  tags          = "${local.env_tags}"

  region        = "${var.region}"
  acl           = "private"
  force_destroy = true
}

output "env_s3_bucket_url" {
  value = "https://${aws_s3_bucket.env.bucket_domain_name}"
}
