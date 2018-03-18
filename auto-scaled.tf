module "example_auto_scaled" {
  source = "./auto-scaling-group"

  name                    = "example"
  key_name                = "${aws_key_pair.ssh.key_name}"
  iam_instance_profile_id = "${aws_iam_instance_profile.ec2.id}"
  subnet_ids              = ["${aws_subnet.public.*.id}"]

  security_group_ids = [
    "${aws_vpc.example.default_security_group_id}",
    "${aws_security_group.http_server.id}",
  ]

  tags = [
    {
      key                 = "Env"
      value               = "${local.default_tags["Env"]}"
      propagate_at_launch = true
    },
    {
      key                 = "Platform"
      value               = "${local.default_tags["Platform"]}"
      propagate_at_launch = true
    },
    {
      key                 = "Provisioner"
      value               = "${local.default_tags["Provisioner"]}"
      propagate_at_launch = true
    },
  ]
}
