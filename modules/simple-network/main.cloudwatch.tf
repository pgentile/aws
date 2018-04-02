resource "aws_flow_log" "flow_logs" {
  log_group_name = "${aws_cloudwatch_log_group.flow_logs.name}"
  iam_role_arn   = "${aws_iam_role.flow_logs.arn}"
  vpc_id         = "${aws_vpc.this.id}"
  traffic_type   = "REJECT"
}

resource "aws_cloudwatch_log_group" "flow_logs" {
  name              = "${var.name}-vpc-flow-logs"
  retention_in_days = 1

  tags = "${local.tags}"
}
