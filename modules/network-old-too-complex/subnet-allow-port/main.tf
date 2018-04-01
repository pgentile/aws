resource "aws_network_acl_rule" "egress" {
  count = "${length(var.ingress_cidr_blocks)}"

  network_acl_id = "${var.egress_network_acl_id}"
  egress         = true
  rule_number    = "${var.first_rule_number + count.index}"
  protocol       = "${var.protocol}"
  rule_action    = "allow"
  cidr_block     = "${element(var.ingress_cidr_blocks, count.index)}"
  from_port      = "${var.port}"
  to_port        = "${var.port}"
}

resource "aws_network_acl_rule" "ingress" {
  count = "${length(var.egress_cidr_blocks)}"

  network_acl_id = "${var.ingress_network_acl_id}"
  egress         = false
  rule_number    = "${var.first_rule_number + aws_network_acl_rule.egress.count + count.index}"
  protocol       = "${var.protocol}"
  rule_action    = "allow"
  cidr_block     = "${element(var.egress_cidr_blocks, count.index)}"
  from_port      = "${var.port}"
  to_port        = "${var.port}"
}

locals {
  next_rule_number = "${var.first_rule_number + aws_network_acl_rule.egress.count + aws_network_acl_rule.ingress.count}"
}
