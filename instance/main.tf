locals {
  tags = "${merge(var.tags, map("Name", var.name))}"
}

resource "aws_instance" "this" {
  ami           = "${data.aws_ami.debian.id}"
  instance_type = "t2.micro"

  vpc_security_group_ids = ["${var.vpc_security_group_ids}"]

  // Normalement, on ne devrait pas faire ça, mais bon...
  // On ne va pas payer pour un Gatway NAT !
  // Ou alors, il nous faudrait une NAT instance
  // Si on n'a pas d'IP public, par contre, impossible de sortir sur Internet
  associate_public_ip_address = true

  subnet_id            = "${var.subnet_id}"
  key_name             = "${var.key_name}"
  user_data            = "${file("${path.module}/instance-init.sh")}"
  iam_instance_profile = "${var.iam_instance_profile_id}"

  root_block_device {
    volume_size = 8
  }

  tags        = "${local.tags}"
  volume_tags = "${local.tags}"
}

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
