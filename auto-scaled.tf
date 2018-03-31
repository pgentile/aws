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

  tags = "${local.default_tags}"
}
