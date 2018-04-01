resource "aws_lb" "load_balancer" {
  name = "load-balancer"

  load_balancer_type = "application"
  subnets            = ["${module.network.subnet_ids}"]
  security_groups    = ["${module.security_group.security_group_id}"]

  tags = "${local.platform_tags}"
}

/*
resource "aws_lb_listener" "example" {
  count = "${var.enable_load_balancer ? 1 : 0}"

  load_balancer_arn = "${aws_lb.example.arn}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.example.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "example" {
  count = "${var.enable_load_balancer ? 1 : 0}"

  name     = "example-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.example.id}"

  tags = "${local.default_tags}"
}

resource "aws_lb_target_group_attachment" "example" {
  count = "${var.enable_load_balancer ? 1 : 0}"

  target_group_arn = "${aws_lb_target_group.example.arn}"
  target_id        = "${module.example_instance.id}"
  port             = 80
}
*/


/*
output "example_lb_url" {
  description = "Example load balancer URL"
  value       = "http://${aws_lb.example.dns_name}"
}
*/

