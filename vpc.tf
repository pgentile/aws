locals {
  vpc_tags = {
    Name        = "example"
    Provisioner = "terraform"
  }
}

resource "aws_vpc" "example" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = "${local.vpc_tags}"
}

resource "aws_default_network_acl" "example" {
  default_network_acl_id = "${aws_vpc.example.default_network_acl_id}"

  egress {
    protocol   = -1
    rule_no    = 9999
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = "${local.vpc_tags}"
}

resource "aws_default_security_group" "example" {
  vpc_id = "${aws_vpc.example.id}"

  egress {
    description = "ALL"
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${local.vpc_tags}"
}

resource "aws_default_route_table" "example" {
  default_route_table_id = "${aws_vpc.example.default_route_table_id}"

  tags = "${merge(local.vpc_tags, map("Name", "private"))}"
}

resource "aws_vpc_dhcp_options" "example" {
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = "${local.vpc_tags}"
}

resource "aws_vpc_dhcp_options_association" "example" {
  vpc_id          = "${aws_vpc.example.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.example.id}"
}

locals {
  vpc_public_cidr_block  = "${cidrsubnet(aws_vpc.example.cidr_block, 1, 0)}"
  vpc_private_cidr_block = "${cidrsubnet(aws_vpc.example.cidr_block, 1, 1)}"
}

resource "aws_subnet" "private" {
  count             = "${length(local.availability_zones)}"
  availability_zone = "${element(local.availability_zones, count.index)}"
  vpc_id            = "${aws_vpc.example.id}"
  cidr_block        = "${cidrsubnet(local.vpc_private_cidr_block, 4, count.index + 1)}"

  tags = "${merge(local.vpc_tags, map("Name", "private"))}"
}

resource "aws_subnet" "public" {
  count             = "${length(local.availability_zones)}"
  availability_zone = "${element(local.availability_zones, count.index)}"
  vpc_id            = "${aws_vpc.example.id}"
  cidr_block        = "${cidrsubnet(local.vpc_public_cidr_block, 4, count.index + 1)}"

  tags = "${merge(local.vpc_tags, map("Name", "public"))}"
}

resource "aws_internet_gateway" "example" {
  vpc_id = "${aws_vpc.example.id}"

  tags = "${merge(local.vpc_tags)}"
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.example.id}"

  route {
    cidr_block = "0.0.0.0/24"
    gateway_id = "${aws_internet_gateway.example.id}"
  }

  tags = "${merge(local.vpc_tags, map("Name", "public"))}"
}

resource "aws_route_table_association" "public" {
  count          = "${aws_subnet.public.count}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}
