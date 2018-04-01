locals {
  tags = "${merge(var.tags, map("Name", var.name))}"
}

resource "aws_instance" "this" {
  ami           = "${data.aws_ami.aws_nat.id}"
  instance_type = "t2.micro"

  vpc_security_group_ids = ["${var.security_group_ids}"]

  associate_public_ip_address = true
  source_dest_check           = false
  subnet_id                   = "${var.subnet_id}"
  key_name                    = "${var.key_name}"

  root_block_device {
    volume_size = 8
  }

  tags        = "${local.tags}"
  volume_tags = "${local.tags}"
}

// See the AWS doc: https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_NAT_Instance.html
data "aws_ami" "aws_nat" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-vpc-nat-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
