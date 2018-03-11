locals {
  private_network_cidr = "${cidrsubnet(var.cidr_block, 1, 0)}"

  remaining_network_cidr = "${cidrsubnet(var.cidr_block, 1, 1)}"
  public_network_cidr    = "${cidrsubnet(local.remaining_network_cidr, 2, 0)}"
}

module "network" {
  source     = "./vpc"
  name       = "network"
  cidr_block = "${var.cidr_block}"

  public_availability_zones = "${var.availability_zones}"

  public_cidr_blocks = [
    "${cidrsubnet(local.public_network_cidr, 3, 0)}",
    "${cidrsubnet(local.public_network_cidr, 3, 1)}",
  ]

  private_availability_zones = "${var.availability_zones}"

  private_cidr_blocks = [
    "${cidrsubnet(local.private_network_cidr, 3, 0)}",
    "${cidrsubnet(local.private_network_cidr, 3, 1)}",
  ]

  tags = "${local.default_tags}"
}
