locals {
  vpc_public_cidr_block  = "${cidrsubnet(var.cidr_block, 1, 0)}"
  vpc_private_cidr_block = "${cidrsubnet(var.cidr_block, 1, 1)}"

  public_subnets = [
    "${cidrsubnet(local.vpc_public_cidr_block, 1, 0)}",
    "${cidrsubnet(local.vpc_public_cidr_block, 1, 1)}",
  ]

  private_subnets = [
    "${cidrsubnet(local.vpc_private_cidr_block, 1, 0)}",
    "${cidrsubnet(local.vpc_private_cidr_block, 1, 1)}",
  ]
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc"

  cidr            = "${var.cidr_block}"
  azs             = "${var.availability_zones}"
  public_subnets  = "${local.public_subnets}"
  private_subnets = "${local.private_subnets}"

  create_database_subnet_group = false
  enable_dns_hostnames         = true

  tags = "${local.default_tags}"
}

module "ssh_bastion_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "ssh-bastion"
  description = "SSH bastion"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress_rules            = ["ssh-tcp"]
  ingress_cidr_blocks      = ["${var.my_ip}/32"]
  ingress_ipv6_cidr_blocks = []

  egress_rules            = ["ssh-tcp"]
  egress_cidr_blocks      = ["${var.cidr_block}"]
  egress_ipv6_cidr_blocks = []

  tags = "${local.default_tags}"
}

resource "aws_security_group_rule" "allow_ssh_from_bastion" {
  security_group_id        = "${module.vpc.default_security_group_id}"
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = "${module.ssh_bastion_sg.this_security_group_id}"
}
