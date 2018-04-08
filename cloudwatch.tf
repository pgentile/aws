resource "aws_cloudwatch_log_group" "docker_logs" {
  name              = "docker-logs"
  retention_in_days = 1

  tags = "${local.env_tags}"
}
