resource "aws_lb" "example" {
  count = "${var.enable_load_balancer ? 1 : 0}"

  name    = "example"
  subnets = ["${aws_subnet.public.*.id}"]

  security_groups = [
    "${aws_vpc.example.default_security_group_id}",
    "${aws_security_group.http_server.id}",
  ]

  tags = "${local.default_tags}"
}

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
  count = "${var.enable_load_balancer ? aws_instance.example.count : 0}"

  target_group_arn = "${aws_lb_target_group.example.arn}"
  target_id        = "${element(aws_instance.example.*.id, count.index)}"
  port             = 80
}

/*
output "example_lb_url" {
  description = "Example load balancer URL"
  value       = "http://${aws_lb.example.dns_name}"
}
*/

