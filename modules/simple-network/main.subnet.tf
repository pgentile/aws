locals {
  subnet_names = "${formatlist("%s-%s", var.name, var.availability_zones)}"
}

resource "aws_subnet" "this" {
  count = "${length(var.subnet_cidr_blocks)}"

  availability_zone = "${element(var.availability_zones, count.index)}"
  vpc_id            = "${aws_vpc.this.id}"
  cidr_block        = "${element(var.subnet_cidr_blocks, count.index)}"

  tags = "${merge(local.tags, map("Name", element(local.subnet_names, count.index)))}"
}

resource "aws_route_table" "this" {
  vpc_id = "${aws_vpc.this.id}"

  tags = "${local.tags}"
}

resource "aws_route_table_association" "this" {
  count = "${aws_subnet.this.count}"

  subnet_id      = "${element(aws_subnet.this.*.id, count.index)}"
  route_table_id = "${aws_route_table.this.id}"
}

resource "aws_route" "internet_gateway" {
  route_table_id         = "${aws_route_table.this.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.internet_gateway.id}"
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = "${aws_vpc.this.id}"

  tags = "${local.tags}"
}

resource "aws_network_acl" "this" {
  vpc_id     = "${aws_vpc.this.id}"
  subnet_ids = ["${aws_subnet.this.*.id}"]

  tags = "${local.tags}"
}

// Allow traffic with allowed CIDR blocks

resource "aws_network_acl_rule" "ingress_allowed_traffic" {
  count = "${length(var.allowed_cidr_blocks)}"

  network_acl_id = "${aws_network_acl.this.id}"
  egress         = false
  rule_number    = "${8000 + count.index}"
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = "${element(var.allowed_cidr_blocks, count.index)}"
}

resource "aws_network_acl_rule" "egress_allowed_traffic" {
  count = "${length(var.allowed_cidr_blocks)}"

  network_acl_id = "${aws_network_acl.this.id}"
  egress         = true
  rule_number    = "${8000 + count.index}"
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = "${element(var.allowed_cidr_blocks, count.index)}"
}

// Subnet internal traffic

resource "aws_network_acl_rule" "ingress_internal_subnet_traffic" {
  network_acl_id = "${aws_network_acl.this.id}"
  egress         = false
  rule_number    = 9000
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = "${var.cidr_block}"
}

resource "aws_network_acl_rule" "egress_internal_subnet_traffic" {
  network_acl_id = "${aws_network_acl.this.id}"
  egress         = true
  rule_number    = 9000
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = "${var.cidr_block}"
}

// Allow external calls to any resource

resource "aws_network_acl_rule" "egress_external_all" {
  network_acl_id = "${aws_network_acl.this.id}"
  egress         = true
  rule_number    = 9100
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

// Ephemeral ports for client traffic

resource "aws_network_acl_rule" "egress_ephemeral_tcp" {
  network_acl_id = "${aws_network_acl.this.id}"
  egress         = false
  rule_number    = 9200
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = "${var.ephemeral_ports["start"]}"
  to_port        = "${var.ephemeral_ports["end"]}"
}

resource "aws_network_acl_rule" "egress_ephemeral_udp" {
  network_acl_id = "${aws_network_acl.this.id}"
  egress         = false
  rule_number    = 9201
  protocol       = "udp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = "${var.ephemeral_ports["start"]}"
  to_port        = "${var.ephemeral_ports["end"]}"
}
