locals {
  subnet_tags = {
    Subnet = "${var.name}"
    Name   = "${var.name}"
  }

  tags = "${merge(var.tags, local.subnet_tags)}"

  subnet_names = "${formatlist("%s-%s", var.name, var.availability_zones)}"
}

resource "aws_subnet" "this" {
  count = "${length(var.cidr_blocks)}"

  availability_zone = "${element(var.availability_zones, count.index)}"
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${element(var.cidr_blocks, count.index)}"

  tags = "${merge(local.tags, map("Name", element(local.subnet_names, count.index)))}"
}

resource "aws_route_table" "this" {
  vpc_id = "${var.vpc_id}"

  tags = "${local.tags}"
}

resource "aws_route_table_association" "this" {
  count = "${aws_subnet.this.count}"

  subnet_id      = "${element(aws_subnet.this.*.id, count.index)}"
  route_table_id = "${aws_route_table.this.id}"
}

resource "aws_route" "internet_gateway" {
  count = "${var.internet_gateway_id == "" ? 0 : 1}"

  route_table_id         = "${aws_route_table.this.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${var.internet_gateway_id}"
}

resource "aws_network_acl" "this" {
  vpc_id     = "${var.vpc_id}"
  subnet_ids = ["${aws_subnet.this.*.id}"]

  tags = "${local.tags}"
}

// Subnet internal traffic

resource "aws_network_acl_rule" "ingress_internal_subnet_traffic" {
  count          = "${var.allow_internal_subnet_traffic ? length(var.cidr_blocks) : 0}"
  network_acl_id = "${aws_network_acl.this.id}"
  egress         = false
  rule_number    = "${9000 + count.index}"
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = "${element(var.cidr_blocks, count.index)}"
}

resource "aws_network_acl_rule" "egress_internal_subnet_traffic" {
  count          = "${var.allow_internal_subnet_traffic ? length(var.cidr_blocks) : 0}"
  network_acl_id = "${aws_network_acl.this.id}"
  egress         = true
  rule_number    = "${9200 + count.index}"
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = "${element(var.cidr_blocks, count.index)}"
}

// External calls to HTTP / HTTPS / HKP services

resource "aws_network_acl_rule" "egress_public_http" {
  network_acl_id = "${aws_network_acl.this.id}"
  egress         = true
  rule_number    = 9300
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "egress_public_https" {
  network_acl_id = "${aws_network_acl.this.id}"
  egress         = true
  rule_number    = 9301
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

// HKP port, to retreive GPG keys with tools like apt
resource "aws_network_acl_rule" "egress_public_hkp" {
  network_acl_id = "${aws_network_acl.this.id}"
  egress         = true
  rule_number    = 9302
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 11371
  to_port        = 11371
}

// Ephemeral ports created by clients

resource "aws_network_acl_rule" "ingress_ephemeral_tcp" {
  network_acl_id = "${aws_network_acl.this.id}"
  egress         = false
  rule_number    = 9400
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = "${var.ephemeral_ports["start"]}"
  to_port        = "${var.ephemeral_ports["end"]}"
}

resource "aws_network_acl_rule" "ingress_ephemeral_udp" {
  network_acl_id = "${aws_network_acl.this.id}"
  egress         = false
  rule_number    = 9401
  protocol       = "udp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = "${var.ephemeral_ports["start"]}"
  to_port        = "${var.ephemeral_ports["end"]}"
}
