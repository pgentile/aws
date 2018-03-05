resource "aws_lb" "example" {
  name            = "TerraformLB"
  subnets         = ["${aws_default_subnet.default.*.id}"]
  security_groups = ["${aws_default_security_group.default.id}"]

  tags {
    Provisioner = "terraform"
  }
}

resource "aws_lb_listener" "example_http" {
  load_balancer_arn = "${aws_lb.example.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.example.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "example" {
  name     = "example-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_default_vpc.default.id}"

  tags {
    Provisioner = "terraform"
  }
}

resource "aws_lb_target_group_attachment" "example" {
  count            = "${aws_instance.example.count}"
  target_group_arn = "${aws_lb_target_group.example.arn}"
  target_id        = "${element(aws_instance.example.*.id, count.index)}"
  port             = 80
}

output "example_lb_url" {
  description = "Example load balancer URL"
  value       = "http://${aws_lb.example.dns_name}"
}
