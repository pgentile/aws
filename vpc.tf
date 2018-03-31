locals {
  vpc_public_cidr_block  = "${cidrsubnet(aws_vpc.example.cidr_block, 1, 0)}"
  vpc_private_cidr_block = "${cidrsubnet(aws_vpc.example.cidr_block, 1, 1)}"
  ephemeral_ports_start  = 1024
  ephemeral_ports_end    = 65535
}

resource "aws_vpc" "example" {
  cidr_block           = "${var.cidr_block}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = "${local.default_tags}"
}

resource "aws_default_security_group" "example" {
  vpc_id = "${aws_vpc.example.id}"

  tags = "${merge(local.default_tags, map("Name", "default"))}"
}

resource "aws_default_route_table" "example" {
  default_route_table_id = "${aws_vpc.example.default_route_table_id}"

  tags = "${merge(local.default_tags, map("Name", "default"))}"
}

resource "aws_vpc_dhcp_options" "example" {
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = "${local.default_tags}"
}

resource "aws_vpc_dhcp_options_association" "example" {
  vpc_id          = "${aws_vpc.example.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.example.id}"
}

resource "aws_default_network_acl" "example" {
  default_network_acl_id = "${aws_vpc.example.default_network_acl_id}"

  tags = "${merge(local.default_tags, map("Name", "default"))}"
}

resource "aws_security_group" "base" {
  name   = "base"
  vpc_id = "${aws_vpc.example.id}"

  // SSH server in the VPC
  ingress {
    description = "ssh"
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr_block}"]
    from_port   = 22
    to_port     = 22
  }

  // HTTP clients
  egress {
    description = "http"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
  }

  // HTTPS clients
  egress {
    description = "https"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
  }

  // HKP port, to retreive GPG keys
  egress {
    description = "hkp"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 11371
    to_port     = 11371
  }

  tags = "${merge(local.default_tags, map("Name", "base"))}"
}

resource "aws_subnet" "private" {
  count             = "${length(var.availability_zones)}"
  availability_zone = "${element(var.availability_zones, count.index)}"
  vpc_id            = "${aws_vpc.example.id}"
  cidr_block        = "${cidrsubnet(local.vpc_private_cidr_block, 3, count.index)}"

  tags = "${merge(local.default_tags, map("Name", "private"))}"
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.example.id}"

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = "${module.nat_instance.id}"
  }

  tags = "${merge(local.default_tags, map("Name", "private"))}"
}

resource "aws_route_table_association" "private" {
  count          = "${aws_subnet.private.count}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_network_acl" "private" {
  vpc_id     = "${aws_vpc.example.id}"
  subnet_ids = ["${aws_subnet.private.*.id}"]

  ingress {
    rule_no    = 1
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "${module.ssh_bastion.private_ip}/32"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    rule_no    = 2
    protocol   = "tcp"
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    rule_no    = 3
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

  // HKP port, to retreive GPG keys
  egress {
    rule_no    = 3
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 11371
    to_port    = 11371
  }

  // HKP port, to retreive GPG keys
  egress {
    rule_no    = 4
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = "${local.ephemeral_ports_start}"
    to_port    = "${local.ephemeral_ports_end}"
  }

  tags = "${merge(local.default_tags, map("Name", "private"))}"
}

resource "aws_subnet" "public" {
  count             = "${length(var.availability_zones)}"
  availability_zone = "${element(var.availability_zones, count.index)}"
  vpc_id            = "${aws_vpc.example.id}"
  cidr_block        = "${cidrsubnet(local.vpc_public_cidr_block, 3, aws_subnet.private.count + count.index)}"

  tags = "${merge(local.default_tags, map("Name", "public"))}"
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

resource "aws_internet_gateway" "example" {
  vpc_id = "${aws_vpc.example.id}"

  tags = "${merge(local.default_tags)}"
}

resource "aws_network_acl" "public" {
  vpc_id     = "${aws_vpc.example.id}"
  subnet_ids = ["${aws_subnet.public.*.id}"]

  tags = "${merge(local.default_tags, map("Name", "public"))}"
}

resource "aws_network_acl_rule" "public_ingress_http_server" {
  network_acl_id = "${aws_network_acl.public.id}"
  egress         = false
  rule_number    = 1
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "public_ingress_ssh_bastion" {
  network_acl_id = "${aws_network_acl.public.id}"
  egress         = false
  rule_number    = 2
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "${var.my_ip}/32"
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "public_ingress_ssh_from_bastion" {
  network_acl_id = "${aws_network_acl.public.id}"
  egress         = false
  rule_number    = 3
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "${module.ssh_bastion.private_ip}/32"
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "public_ingress_ssh_other" {
  network_acl_id = "${aws_network_acl.public.id}"
  egress         = false
  rule_number    = 4
  protocol       = "tcp"
  rule_action    = "deny"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "public_ingress_all" {
  network_acl_id = "${aws_network_acl.public.id}"
  egress         = false
  rule_number    = 5
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = "${local.ephemeral_ports_start}"
  to_port        = "${local.ephemeral_ports_end}"
}

resource "aws_network_acl_rule" "public_egress_ssh_client" {
  network_acl_id = "${aws_network_acl.public.id}"
  egress         = true
  rule_number    = 1
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "${aws_vpc.example.cidr_block}"
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "public_egress_http_client" {
  network_acl_id = "${aws_network_acl.public.id}"
  egress         = true
  rule_number    = 2
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "public_egress_https_client" {
  network_acl_id = "${aws_network_acl.public.id}"
  egress         = true
  rule_number    = 3
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

// HKP port, to retreive GPG keys
resource "aws_network_acl_rule" "public_egress_hkp_client" {
  network_acl_id = "${aws_network_acl.public.id}"
  egress         = true
  rule_number    = 4
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 11371
  to_port        = 11371
}

resource "aws_network_acl_rule" "public_egress_all" {
  network_acl_id = "${aws_network_acl.public.id}"
  egress         = true
  rule_number    = 5
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = "${local.ephemeral_ports_start}"
  to_port        = "${local.ephemeral_ports_end}"
}

resource "aws_security_group" "http_server" {
  name   = "http-server"
  vpc_id = "${aws_vpc.example.id}"

  // HTTP server
  ingress {
    description = "http"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(local.default_tags, map("Name", "http-server"))}"
}

resource "aws_security_group" "ssh_bastion" {
  name   = "ssh-bastion"
  vpc_id = "${aws_vpc.example.id}"

  // SSH server from my IP
  ingress {
    description = "ssh"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["${var.my_ip}/32"]
  }

  // SSH client in the VPC
  egress {
    description = "ssh"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["${aws_vpc.example.cidr_block}"]
  }

  tags = "${merge(local.default_tags, map("Name", "ssh-bastion"))}"
}

resource "aws_security_group" "nat_instance" {
  name   = "nat-instance"
  vpc_id = "${aws_vpc.example.id}"

  // HTTP server

  ingress {
    description = "http"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["${var.cidr_block}"]
  }
  egress {
    description = "http"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  // HTTPS server

  ingress {
    description = "http"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["${var.cidr_block}"]
  }
  egress {
    description = "http"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  // HKP to retreive GPG keys

  ingress {
    description = "http"
    protocol    = "tcp"
    from_port   = 11371
    to_port     = 11371
    cidr_blocks = ["${var.cidr_block}"]
  }
  egress {
    description = "http"
    protocol    = "tcp"
    from_port   = 11371
    to_port     = 11371
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = "${merge(local.default_tags, map("Name", "nat-instance"))}"
}
