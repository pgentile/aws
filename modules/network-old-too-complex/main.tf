data "aws_availability_zones" "az" {}

locals {
  name_tags = {
    Name = "${var.name}"
  }

  tags = "${merge(var.tags, local.name_tags)}"

  availability_zones = "${sort(coalescelist(
    var.availability_zones,
    data.aws_availability_zones.az.names
  ))}"
}

module "vpc" {
  source = "./vpc"

  name       = "${var.name}"
  cidr_block = "${var.cidr_block}"
  tags       = "${var.tags}"
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = "${module.vpc.id}"

  tags = "${local.tags}"
}

module "public_subnet" {
  source = "./subnet"

  name   = "public"
  vpc_id = "${module.vpc.id}"

  internet_gateway_id = "${aws_internet_gateway.internet_gateway.id}"

  availability_zones = ["${local.availability_zones}"]
  cidr_blocks        = ["${var.public_subnet_cidr_blocks}"]
  tags               = "${var.tags}"
}

module "private_subnet" {
  source = "./subnet"

  name   = "private"
  vpc_id = "${module.vpc.id}"

  availability_zones = ["${local.availability_zones}"]
  cidr_blocks        = ["${var.private_subnet_cidr_blocks}"]

  allow_internal_subnet_traffic = true

  tags = "${var.tags}"
}

module "database_subnet" {
  source = "./subnet"

  name   = "database"
  vpc_id = "${module.vpc.id}"

  availability_zones = ["${local.availability_zones}"]
  cidr_blocks        = ["${var.database_subnet_cidr_blocks}"]

  allow_internal_subnet_traffic = true

  tags = "${var.tags}"
}
