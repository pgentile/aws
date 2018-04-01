locals {
  tags = "${merge(var.tags, map("Name", var.name))}"
}

resource "aws_instance" "this" {
  ami           = "${module.instance_config.ami_id}"
  instance_type = "t2.micro"

  vpc_security_group_ids = ["${var.security_group_ids}"]

  associate_public_ip_address = "${var.associate_public_ip_address}"

  subnet_id            = "${var.subnet_id}"
  key_name             = "${var.key_name}"
  user_data            = "${module.instance_config.user_data}"
  iam_instance_profile = "${var.iam_instance_profile_id}"

  root_block_device {
    volume_size = 8
  }

  tags        = "${local.tags}"
  volume_tags = "${local.tags}"
}

module "instance_config" {
  source = "../instance-config"

  hostname                   = "${var.name}"
  ssh_allow_tcp_forwarding   = "yes"
  ssh_allow_agent_forwarding = "yes"
}
