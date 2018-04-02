resource "aws_flow_log" "flow_logs" {
  log_group_name = "${aws_cloudwatch_log_group.flow_logs.name}"
  iam_role_arn   = "${aws_iam_role.flow_logs.arn}"
  vpc_id         = "${aws_vpc.this.id}"
  traffic_type   = "REJECT"
}

resource "aws_cloudwatch_log_group" "flow_logs" {
  name              = "vpc-flow-logs-${var.name}"
  retention_in_days = 3

  tags = "${local.tags}"
}
