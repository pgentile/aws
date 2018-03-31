locals {
  public_subnet_cidr_block  = "${cidrsubnet(var.cidr_block, 1, 0)}"
  private_subnet_cidr_block = "${cidrsubnet(var.cidr_block, 1, 1)}"

  public_subnet_cidr_blocks = [
    "${cidrsubnet(local.public_subnet_cidr_block, 1, 0)}",
    "${cidrsubnet(local.public_subnet_cidr_block, 1, 1)}",
  ]

  private_subnet_cidr_blocks = [
    "${cidrsubnet(local.private_subnet_cidr_block, 1, 0)}",
    "${cidrsubnet(local.private_subnet_cidr_block, 1, 1)}",
  ]
}

module "network" {
  source = "./modules/network"

  name                       = "${var.env}"
  cidr_block                 = "${var.cidr_block}"
  public_subnet_cidr_blocks  = "${local.public_subnet_cidr_blocks}"
  private_subnet_cidr_blocks = "${local.private_subnet_cidr_blocks}"
  availability_zones         = "${var.availability_zones}"
  tags                       = "${local.env_tags}"
}
