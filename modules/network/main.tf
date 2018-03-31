locals {
  name_tags = {
    Name = "${var.name}"
  }

  tags = "${merge(var.tags, local.name_tags)}"
}

module "vpc" {
  source = "./vpc"

  name       = "${var.name}"
  cidr_block = "${var.cidr_block}"
  tags       = "${var.tags}"
}

module "public_subnet" {
  source = "./subnet"

  name   = "public"
  vpc_id = "${module.vpc.id}"

  availability_zones = ["${var.availability_zones}"]
  cidr_blocks        = ["${var.public_subnet_cidr_blocks}"]

  tags = "${var.tags}"
}

module "private_subnet" {
  source = "./subnet"

  name   = "private"
  vpc_id = "${module.vpc.id}"

  availability_zones = ["${var.availability_zones}"]
  cidr_blocks        = ["${var.private_subnet_cidr_blocks}"]

  allow_internal_subnet_traffic = true

  tags = "${var.tags}"
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = "${module.vpc.id}"

  tags = "${local.tags}"
}

resource "aws_route" "internet_gateway" {
  route_table_id         = "${module.public_subnet.route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.internet_gateway.id}"
}
