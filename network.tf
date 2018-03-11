locals {
  private_network_cidr = "${cidrsubnet(var.cidr_block, 1, 0)}"

  remaining_network_cidr = "${cidrsubnet(var.cidr_block, 1, 1)}"
  public_network_cidr    = "${cidrsubnet(local.remaining_network_cidr, 2, 0)}"
}

locals {
  private_cidr_blocks = [
    "${cidrsubnet(local.private_network_cidr, 3, 0)}",
    "${cidrsubnet(local.private_network_cidr, 3, 1)}",
  ]
}

resource "aws_vpc" "xxx" {
  cidr_block           = "${var.cidr_block}"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "xxx" {
  count = "${length(var.availability_zones)}"

  vpc_id            = "${aws_vpc.xxx.id}"
  availability_zone = "${var.availability_zones[count.index]}"
  cidr_block        = "${local.private_cidr_blocks[count.index]}"
}

resource "aws_network_acl" "xxx" {
  vpc_id     = "${aws_vpc.xxx.id}"
  subnet_ids = "${aws_subnet.xxx.*.id}"
}

/*
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

  private_gateway_network_interface_id = ""

  tags {
    Provisioner = "Terraform"
    env         = "TEST"
  }
}
*/

