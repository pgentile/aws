locals {
  private_subnet_cidr_block  = "${cidrsubnet(var.cidr_block, 2, 0)}"
  public_subnet_cidr_block   = "${cidrsubnet(var.cidr_block, 2, 1)}"
  database_subnet_cidr_block = "${cidrsubnet(var.cidr_block, 2, 2)}"
}

module "network" {
  source = "./modules/network"

  name       = "${var.env}"
  cidr_block = "${var.cidr_block}"

  public_subnet_cidr_blocks = [
    "${cidrsubnet(local.public_subnet_cidr_block, 2, 0)}",
    "${cidrsubnet(local.public_subnet_cidr_block, 2, 1)}",
    "${cidrsubnet(local.public_subnet_cidr_block, 2, 2)}",
  ]

  private_subnet_cidr_blocks = [
    "${cidrsubnet(local.private_subnet_cidr_block, 2, 0)}",
    "${cidrsubnet(local.private_subnet_cidr_block, 2, 1)}",
    "${cidrsubnet(local.private_subnet_cidr_block, 2, 2)}",
  ]

  database_subnet_cidr_blocks = [
    "${cidrsubnet(local.database_subnet_cidr_block, 2, 0)}",
    "${cidrsubnet(local.database_subnet_cidr_block, 2, 1)}",
    "${cidrsubnet(local.database_subnet_cidr_block, 2, 2)}",
  ]

  tags = "${local.env_tags}"
}
