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
  count = "${var.internet_gateway_id != "" ? 1 : 0}"

  route_table_id         = "${aws_route_table.this.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${var.internet_gateway_id}"
}
