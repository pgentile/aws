module "network" {
  source = "./modules/simple-network"

  name               = "${var.env}"
  cidr_block         = "${var.cidr_block}"
  availability_zones = ["${var.availability_zones}"]

  subnet_cidr_blocks = [
    "${cidrsubnet(var.cidr_block, 1, 0)}",
    "${cidrsubnet(var.cidr_block, 1, 1)}",
  ]

  allowed_cidr_blocks = ["${var.my_ip}/32"]

  tags = "${local.env_tags}"
}

module "security_group" {
  source = "./modules/base-security-group"

  name                = "base"
  vpc_id              = "${module.network.vpc_id}"
  allowed_cidr_blocks = ["${var.my_ip}/32"]

  tags = "${local.env_tags}"
}
