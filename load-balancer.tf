resource "aws_lb" "load_balancer" {
  name = "${var.platform}"
  tags = "${local.platform_tags}"

  name = "load-balancer"

  load_balancer_type = "application"
  subnets            = ["${module.network.subnet_ids}"]
  security_groups    = ["${module.base_security_group.id}"]
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
  name = "${var.platform}"
  tags = "${local.platform_tags}"

  port                 = 80
  protocol             = "HTTP"
  vpc_id               = "${module.network.vpc_id}"
  deregistration_delay = 30
}

output "load_balancer_url" {
  description = "Example load balancer URL"
  value       = "http://${aws_lb.load_balancer.dns_name}"
}
