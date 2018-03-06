locals {
  vpc_public_cidr_block  = "${cidrsubnet(aws_vpc.example.cidr_block, 1, 0)}"
  vpc_private_cidr_block = "${cidrsubnet(aws_vpc.example.cidr_block, 1, 1)}"
  ephemeral_ports_start  = 1024
  ephemeral_ports_end    = 65535
}

resource "aws_vpc" "example" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = "${local.default_tags}"
}

resource "aws_default_network_acl" "example" {
  default_network_acl_id = "${aws_vpc.example.default_network_acl_id}"

  ingress {
    rule_no    = 1
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = "${local.ephemeral_ports_start}"
    to_port    = "${local.ephemeral_ports_end}"
  }

  egress {
    rule_no    = 1
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  egress {
    rule_no    = 2
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  tags = "${merge(local.default_tags, map("Name", "private"))}"
}

resource "aws_default_security_group" "default" {
  vpc_id = "${aws_vpc.example.id}"

  ingress {
    description = "ssh"
    protocol   = "tcp"
    cidr_blocks = ["${aws_vpc.example.cidr_block}"]
    from_port  = 22
    to_port    = 22
  }

  egress {
    description = "http"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
  }

  egress {
    description = "https"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
  }

  tags = "${merge(local.default_tags, map("Name", "default"))}"
}

resource "aws_default_route_table" "example" {
  default_route_table_id = "${aws_vpc.example.default_route_table_id}"

  tags = "${merge(local.default_tags, map("Name", "private"))}"
}

resource "aws_vpc_dhcp_options" "example" {
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = "${local.default_tags}"
}

resource "aws_vpc_dhcp_options_association" "example" {
  vpc_id          = "${aws_vpc.example.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.example.id}"
}

resource "aws_subnet" "private" {
  count             = "${length(local.availability_zones)}"
  availability_zone = "${element(local.availability_zones, count.index)}"
  vpc_id            = "${aws_vpc.example.id}"
  cidr_block        = "${cidrsubnet(local.vpc_private_cidr_block, 4, count.index + 1)}"

  tags = "${merge(local.default_tags, map("Name", "private"))}"
}

resource "aws_subnet" "public" {
  count             = "${length(local.availability_zones)}"
  availability_zone = "${element(local.availability_zones, count.index)}"
  vpc_id            = "${aws_vpc.example.id}"
  cidr_block        = "${cidrsubnet(local.vpc_public_cidr_block, 4, count.index + 1)}"

  tags = "${merge(local.default_tags, map("Name", "public"))}"
}

resource "aws_internet_gateway" "example" {
  vpc_id = "${aws_vpc.example.id}"

  tags = "${merge(local.default_tags)}"
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.example.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.example.id}"
  }

  tags = "${merge(local.default_tags, map("Name", "public"))}"
}

resource "aws_route_table_association" "public" {
  count          = "${aws_subnet.public.count}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_network_acl" "public" {
  vpc_id     = "${aws_vpc.example.id}"
  subnet_ids = ["${aws_subnet.public.*.id}"]

  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "${var.my_ip}/32"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    rule_no    = 101
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "${aws_vpc.example.cidr_block}"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    rule_no    = 200
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    rule_no    = 300
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = "${local.ephemeral_ports_start}"
    to_port    = "${local.ephemeral_ports_end}"
  }

  egress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "${aws_vpc.example.cidr_block}"
    from_port  = 22
    to_port    = 22
  }

  egress {
    rule_no    = 200
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  egress {
    rule_no    = 201
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  egress {
    rule_no    = 300
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = "${local.ephemeral_ports_start}"
    to_port    = "${local.ephemeral_ports_end}"
  }

  tags = "${merge(local.default_tags, map("Name", "public"))}"
}

resource "aws_security_group" "ssh_external" {
  name   = "ssh-external"
  vpc_id = "${aws_vpc.example.id}"

  ingress {
    description = "ssh"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [
      "${var.my_ip}/32",
    ]
  }

  egress {
    description = "ssh"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [
      "${aws_vpc.example.cidr_block}",
    ]
  }

  tags = "${merge(local.default_tags, map("Name", "ssh"))}"
}

resource "aws_security_group" "http" {
  name   = "http"
  vpc_id = "${aws_vpc.example.id}"

  ingress {
    description = "http"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(local.default_tags, map("Name", "http"))}"
}
