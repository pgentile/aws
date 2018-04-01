locals {
  tags = "${merge(var.tags, map("Name", var.name))}"
}

module "instance" {
  source = "../instance"

  name                        = "ssh-bastion"
  key_name                    = "${var.key_name}"
  subnet_id                   = "${var.subnet_id}"
  associate_public_ip_address = true
  ssh_allow_tcp_forwarding    = "yes"
  ssh_allow_agent_forwarding  = "yes"

  security_group_ids = ["${var.security_group_ids}"]

  tags = "${local.tags}"
}
