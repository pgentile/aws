module "example_auto_scaled" {
  source = "./modules/auto-scaling-group"

  name                        = "example"
  key_name                    = "${aws_key_pair.ssh.key_name}"
  iam_instance_profile_id     = "${aws_iam_instance_profile.ec2.id}"
  subnet_ids                  = ["${module.vpc.private_subnets}"]
  associate_public_ip_address = false

  security_group_ids = [
    "${module.base_security_group.this_security_group_id}",
  ]

  tags = "${local.platform_tags}"
}
