resource "aws_s3_bucket" "example" {
  bucket_prefix = "pgentile-"
  acl    = "private"

  tags {
    Name = "Example Bucket"
    Provisioner = "terraform"
  }
}
