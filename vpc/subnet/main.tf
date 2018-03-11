resource "aws_subnet" "this" {
  count = "${length(var.availability_zones)}"

  vpc_id            = "${var.vpc_id}"
  availability_zone = "${var.availability_zones[count.index]}"
  cidr_block        = "${var.cidr_blocks[count.index]}"

  tags = "${merge(local.default_tags, map("Name", local.network_names[count.index]))}"
}

resource "aws_route_table" "this" {
  vpc_id = "${var.vpc_id}"
  tags   = "${local.default_tags}"
}

resource "aws_route_table_association" "this" {
  count          = "${length(var.availability_zones)}"
  subnet_id      = "${element(aws_subnet.this.*.id, count.index)}"
  route_table_id = "${aws_route_table.this.id}"
}

resource "aws_route" "internet_gateway" {
  count = "${var.public == 1 ? 1 : 0}"

  route_table_id         = "${aws_route_table.this.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.this.id}"
}

resource "aws_internet_gateway" "this" {
  count = "${var.public == 1 ? 1 : 0}"

  vpc_id = "${var.vpc_id}"

  tags = "${local.default_tags}"
}

// Can't use aws_subnet.this.*.id
// This is a workaround to repeat the ACL and use the deprecated subnet_id field

resource "aws_network_acl" "this" {
  count = "${length(var.availability_zones)}"

  vpc_id    = "${var.vpc_id}"
  subnet_id = "${element(aws_subnet.this.*.id, count.index)}"

  tags = "${merge(local.default_tags, map("Name", local.network_names[count.index]))}"
}

resource "aws_network_acl_rule" "ingress_tcp_all" {
  count = "${length(var.availability_zones)}"

  network_acl_id = "${element(aws_network_acl.this.*.id, count.index)}"
  rule_number    = 9999
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}
