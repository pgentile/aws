resource "aws_security_group" "this" {
  name        = "${var.name}"
  description = "Base security group to use"
  vpc_id      = "${var.vpc_id}"

  tags = "${merge(var.tags, map("Name", "${var.name}"))}"
}

resource "aws_security_group_rule" "base_ingress_allowed" {
  security_group_id = "${aws_security_group.this.id}"

  type        = "ingress"
  protocol    = -1
  from_port   = -1
  to_port     = -1
  cidr_blocks = ["${var.allowed_cidr_blocks}"]
}

resource "aws_security_group_rule" "base_egress_all" {
  security_group_id = "${aws_security_group.this.id}"

  type        = "egress"
  protocol    = -1
  from_port   = -1
  to_port     = -1
  cidr_blocks = ["0.0.0.0/0"]
}
