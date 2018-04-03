locals {
  log_groups = [
    "coreos-docker-logs",
  ]
}

resource "aws_cloudwatch_log_group" "flow_logs" {
  count = "${length(local.log_groups)}"

  name              = "${element(local.log_groups, count.index)}"
  retention_in_days = 1

  tags = "${local.env_tags}"
}
