module "ecs_auto_scaling" {
  source = "./modules/ecs-auto-scaling"

  name = "${var.platform}"
  tags = "${local.platform_tags}"

  key_name                    = "${aws_key_pair.ssh.key_name}"
  subnet_ids                  = ["${module.network.subnet_ids}"]
  associate_public_ip_address = true

  security_group_ids = [
    "${module.base_security_group.id}",
  ]

  instance_config_s3_bucket_id   = "${aws_s3_bucket.env.id}"
  instance_config_s3_bucket_arn  = "${aws_s3_bucket.env.arn}"
  instance_config_s3_domain_name = "${aws_s3_bucket.env.bucket_domain_name}"
}
