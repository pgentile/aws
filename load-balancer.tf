resource "aws_lb" "load_balancer" {
  name = "load-balancer"

  load_balancer_type = "application"
  subnets            = ["${module.network.subnet_ids}"]
  security_groups    = ["${module.security_group.security_group_id}"]

  tags = "${local.platform_tags}"
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = "${aws_lb.load_balancer.arn}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.default.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "default" {
  name                 = "http-target-group"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = "${module.network.vpc_id}"
  deregistration_delay = 30

  tags = "${local.platform_tags}"
}

output "example_lb_url" {
  description = "Example load balancer URL"
  value       = "http://${aws_lb.load_balancer.dns_name}"
}
