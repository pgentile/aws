module "example_instance" {
  source = "./instance"

  name                    = "example"
  key_name                = "${aws_key_pair.ssh.key_name}"
  iam_instance_profile_id = "${aws_iam_instance_profile.ec2.id}"
  subnet_id               = "${aws_subnet.public.*.id[0]}"

  vpc_security_group_ids = [
    "${aws_vpc.example.default_security_group_id}",
    "${aws_security_group.http_server.id}",
  ]

  tags = "${local.default_tags}"
}

output "example_private_ip" {
  description = "Example private IP"
  value       = "${module.example_instance.private_ip}"
}
