resource "aws_vpc" "this" {
  cidr_block           = "${var.cidr_block}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = "${local.default_tags}"
}

resource "aws_default_network_acl" "this" {
  default_network_acl_id = "${aws_vpc.this.default_network_acl_id}"
  tags                   = "${local.default_tags}"
}

resource "aws_default_security_group" "this" {
  vpc_id = "${aws_vpc.this.id}"
  tags   = "${local.default_tags}"
}

resource "aws_default_route_table" "this" {
  default_route_table_id = "${aws_vpc.this.default_route_table_id}"
  tags                   = "${local.default_tags}"
}

resource "aws_vpc_dhcp_options" "this" {
  domain_name_servers = ["AmazonProvidedDNS"]
  tags                = "${local.default_tags}"
}

resource "aws_vpc_dhcp_options_association" "this" {
  vpc_id          = "${aws_vpc.this.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.this.id}"
}

resource "aws_internet_gateway" "this" {
  vpc_id = "${aws_vpc.this.id}"
  tags   = "${merge(local.default_tags)}"
}

module "public_network" {
  source = "./subnet"

  name               = "public"
  vpc_id             = "${aws_vpc.this.id}"
  availability_zones = "${var.public_availability_zones}"
  cidr_blocks        = "${var.public_cidr_blocks}"

  internet_gateway_id = "${aws_internet_gateway.this.id}"
}

module "private_network" {
  source = "./subnet"

  name               = "private"
  vpc_id             = "${aws_vpc.this.id}"
  availability_zones = "${var.private_availability_zones}"
  cidr_blocks        = "${var.private_cidr_blocks}"
}
