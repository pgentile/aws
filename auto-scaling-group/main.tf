locals {
  extra_tags = "${list(map("key", "AutoscalingGroup", "value", var.name, "propagate_at_launch", true))}"
}

resource "aws_autoscaling_group" "this" {
  name                 = "${var.name}"
  min_size             = 1
  max_size             = 1
  launch_configuration = "${aws_launch_configuration.this.name}"
  vpc_zone_identifier  = ["${var.subnet_ids}"]

  tags = ["${concat(var.tags, local.extra_tags)}"]
}

resource "aws_launch_configuration" "this" {
  name                 = "${var.name}"
  instance_type        = "t2.micro"
  image_id             = "${module.instance_config.ami_id}"
  iam_instance_profile = "${var.iam_instance_profile_id}"
  key_name             = "${var.key_name}"
  user_data            = "${module.instance_config.user_data}"
  security_groups      = ["${var.security_group_ids}"]

  // Normalement, on ne devrait pas faire ça, mais bon...
  // On ne va pas payer pour un Gatway NAT !
  // Ou alors, il nous faudrait une NAT instance
  // Si on n'a pas d'IP public, par contre, impossible de sortir sur Internet
  associate_public_ip_address = true

  // C'est payant, le monitoring avancé... Alors, on le coupe !
  enable_monitoring = false

  root_block_device {
    volume_size = 8
  }
}

module "instance_config" {
  source = "../instance-config"
}
