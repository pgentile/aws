module "nat_instance" {
  source = "./nat-instance"

  name      = "nat-instance"
  key_name  = "${aws_key_pair.ssh.key_name}"
  subnet_id = "${aws_subnet.public.*.id[0]}"

  security_group_ids = [
    "${aws_security_group.base.id}",
    "${aws_security_group.nat_instance.id}",
  ]

  tags = "${local.default_tags}"
}
