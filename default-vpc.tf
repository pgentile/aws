resource "aws_default_vpc" "default" {
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name        = "Terraform"
    Provisioner = "terraform"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = "${aws_default_vpc.default.id}"

  ingress {
    description = "SSH"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["${var.my_ip}/32"]
  }

  egress {
    description = "ALL"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "Terraform"
    Provisioner = "terraform"
  }
}

resource "aws_default_route_table" "route_table" {
  default_route_table_id = "${aws_default_vpc.default.default_route_table_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags {
    Name        = "Terraform"
    Provisioner = "terraform"
  }
}

data "aws_availability_zones" "availability_zones" {}

resource "aws_default_subnet" "default" {
  count             = "${length(data.aws_availability_zones.availability_zones.names)}"
  availability_zone = "${element(data.aws_availability_zones.availability_zones.names , count.index)}"

  tags {
    Name        = "Terraform / ${element(data.aws_availability_zones.availability_zones.names , count.index)}"
    Provisioner = "terraform"
  }
}

resource "aws_default_network_acl" "default" {
  default_network_acl_id = "${aws_default_vpc.default.default_network_acl_id}"

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags {
    Name        = "Terraform"
    Provisioner = "terraform"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_default_vpc.default.id}"

  tags {
    Name        = "Terraform"
    Provisioner = "terraform"
  }
}

resource "aws_default_vpc_dhcp_options" "default" {
  tags {
    Name        = "Terraform"
    Provisioner = "terraform"
  }
}

resource "aws_route53_zone" "vpc_zone" {
  name   = "example.com"
  vpc_id = "${aws_default_vpc.default.id}"

  tags {
    Name        = "Terraform"
    Provisioner = "terraform"
  }
}
