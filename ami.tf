// See the Debian doc: https://wiki.debian.org/Cloud/AmazonEC2Image/Stretch
data "aws_ami" "debian" {
  most_recent = true

  owners = ["379101102735"]

  filter {
    name   = "name"
    values = ["debian-stretch-hvm-x86_64-gp2-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
