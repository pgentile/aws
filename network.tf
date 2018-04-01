// The VPC

locals {
  private_subnet_cidr_block  = "${cidrsubnet(var.cidr_block, 2, 0)}"
  public_subnet_cidr_block   = "${cidrsubnet(var.cidr_block, 2, 1)}"
  database_subnet_cidr_block = "${cidrsubnet(var.cidr_block, 2, 2)}"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.26.0"

  name = "${var.env}"
  cidr = "${var.cidr_block}"
  azs  = ["${var.availability_zones}"]

  private_subnets = [
    "${cidrsubnet(local.private_subnet_cidr_block, 2, 0)}",
    "${cidrsubnet(local.private_subnet_cidr_block, 2, 1)}",
  ]

  public_subnets = [
    "${cidrsubnet(local.public_subnet_cidr_block, 2, 0)}",
    "${cidrsubnet(local.public_subnet_cidr_block, 2, 1)}",
  ]

  database_subnets = [
    "${cidrsubnet(local.database_subnet_cidr_block, 2, 0)}",
    "${cidrsubnet(local.database_subnet_cidr_block, 2, 1)}",
    "${cidrsubnet(local.database_subnet_cidr_block, 2, 2)}",
  ]

  enable_dhcp_options  = true
  enable_dns_hostnames = true

  tags = "${local.env_tags}"
}

// The NAT instance

module "nat_instance" {
  source = "./modules/nat-instance"

  name               = "nat-instance"
  key_name           = "${aws_key_pair.ssh.key_name}"
  subnet_id          = "${module.vpc.public_subnets[0]}"
  security_group_ids = ["${module.nat_instance_security_group.this_security_group_id}"]

  tags = "${local.env_tags}"
}

module "nat_instance_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "1.20.0"

  name        = "nat-instance"
  description = "NAT instance"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress_cidr_blocks = ["${var.cidr_block}"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]

  ingress_with_cidr_blocks = [
    {
      from_port   = 11371
      to_port     = 11371
      protocol    = "tcp"
      description = "HKP (GPG key servers)"
      cidr_blocks = "${var.cidr_block}"
    },
  ]

  egress_cidr_blocks      = ["0.0.0.0/0"]
  egress_ipv6_cidr_blocks = []
  egress_rules            = ["http-80-tcp", "https-443-tcp"]

  egress_with_cidr_blocks = [
    {
      from_port   = 11371
      to_port     = 11371
      protocol    = "tcp"
      description = "HKP (GPG key servers)"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  tags = "${local.env_tags}"
}

resource "aws_route" "nat_route" {
  count = "${length(module.vpc.private_route_table_ids)}"

  route_table_id         = "${element(module.vpc.private_route_table_ids, count.index)}"
  instance_id            = "${module.nat_instance.id}"
  destination_cidr_block = "0.0.0.0/0"
}

// The SSH bastion

module "ssh_bastion" {
  source = "./modules/ssh-bastion"

  name               = "ssh-bastion"
  key_name           = "${aws_key_pair.ssh.key_name}"
  subnet_id          = "${module.vpc.public_subnets[0]}"
  security_group_ids = ["${module.ssh_bastion_security_group.this_security_group_id}"]

  tags = "${local.env_tags}"
}

module "ssh_bastion_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "1.20.0"

  name        = "ssh-bastion"
  description = "SSH bastion"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress_cidr_blocks      = ["${var.my_ip}/32"]
  ingress_ipv6_cidr_blocks = []
  ingress_rules            = ["ssh-tcp"]

  egress_with_cidr_blocks = [
    {
      description = "SSH"
      rule        = "ssh-tcp"
      cidr_blocks = "${var.cidr_block}"
    },
    {
      description = "HTTP"
      rule        = "http-80-tcp"
      description = "HKP (GPG key servers)"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "HTTPS"
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "HKP (GPG key servers)"
      from_port   = 11371
      to_port     = 11371
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  tags = "${local.env_tags}"
}

// The base security group

module "base_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "1.20.0"

  name        = "base"
  description = "Base security group for instances"
  vpc_id      = "${module.vpc.vpc_id}"

  egress_cidr_blocks      = []
  egress_ipv6_cidr_blocks = []

  ingress_with_self = [
    {
      rule = "all-all"
    },
  ]

  egress_with_self = [
    {
      rule = "all-all"
    },
  ]

  ingress_with_source_security_group_id = [
    {
      description              = "SSH"
      rule                     = "ssh-tcp"
      source_security_group_id = "${module.ssh_bastion_security_group.this_security_group_id}"
    },
  ]

  egress_with_cidr_blocks = [
    {
      description = "HTTP"
      rule        = "http-80-tcp"
      description = "HKP (GPG key servers)"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "HTTPS"
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "HKP (GPG key servers)"
      from_port   = 11371
      to_port     = 11371
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  tags = "${local.env_tags}"
}
