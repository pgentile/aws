module "ssh_bastion" {
  source = "./instance"

  name                       = "ssh-bastion"
  key_name                   = "${aws_key_pair.ssh.key_name}"
  iam_instance_profile_id    = "${aws_iam_instance_profile.ec2.id}"
  subnet_id                  = "${aws_subnet.public.*.id[0]}"
  ssh_allow_tcp_forwarding   = "yes"
  ssh_allow_agent_forwarding = "yes"

  security_group_ids = [
    "${aws_security_group.base.id}",
    "${aws_security_group.ssh_bastion.id}",
  ]

  tags = "${local.default_tags}"
}
