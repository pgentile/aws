locals {
  log_groups = [
    "/var/log/dmesg",
    "/var/log/messages",
    "/var/log/docker",
    "/var/log/ecs/ecs-init.log",
    "/var/log/ecs/ecs-agent.log",
  ]
}

resource "aws_cloudwatch_log_group" "flow_logs" {
  count = "${length(local.log_groups)}"

  name              = "${element(local.log_groups, count.index)}"
  retention_in_days = 1

  tags = "${local.env_tags}"
}
