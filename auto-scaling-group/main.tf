locals {
  tags       = "${merge(var.tags, map("AutoscalingGroup", var.name))}"
  tag_keys   = "${keys(local.tags)}"
  tag_values = "${values(local.tags)}"
}

// We use the null_data_source to create the tag list from the map
// The tags will be propagated to the instance
data "null_data_source" "propagated_tags" {
  count = "${length(local.tags)}"

  inputs = {
    key                 = "${local.tag_keys[count.index]}"
    value               = "${local.tag_values[count.index]}"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "this" {
  name_prefix          = "${var.name}-"
  min_size             = 1
  max_size             = 1
  launch_configuration = "${aws_launch_configuration.this.name}"
  vpc_zone_identifier  = ["${var.subnet_ids}"]

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  tags = ["${data.null_data_source.propagated_tags.*.outputs}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "this" {
  name_prefix          = "${var.name}-"
  instance_type        = "t2.micro"
  image_id             = "${module.instance_config.ami_id}"
  iam_instance_profile = "${var.iam_instance_profile_id}"
  key_name             = "${var.key_name}"
  user_data            = "${module.instance_config.user_data}"
  security_groups      = ["${var.security_group_ids}"]

  associate_public_ip_address = "${var.associate_public_ip_address}"

  // C'est payant, le monitoring avancé... Alors, on le coupe !
  enable_monitoring = false

  root_block_device {
    volume_size = 8
  }

  lifecycle {
    create_before_destroy = true
  }
}

module "instance_config" {
  source = "../instance-config"
}
