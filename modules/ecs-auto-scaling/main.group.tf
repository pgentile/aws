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
  image_id             = "${data.aws_ami.aws_ecs.id}"
  iam_instance_profile = "${aws_iam_instance_profile.ecs.id}"
  key_name             = "${var.key_name}"
  security_groups      = ["${var.security_group_ids}"]

  associate_public_ip_address = "${var.associate_public_ip_address}"

  user_data = "${file("${path.module}/cloud-init.yaml")}"

  // C'est payant, le monitoring avancé... Alors, on le coupe !
  enable_monitoring = false

  // Root device
  root_block_device {
    volume_size = 8
  }

  // Volume used by Docker devicemapper
  ebs_block_device {
    device_name = "/dev/xvdcz"
    volume_size = 22
  }

  lifecycle {
    create_before_destroy = true
  }
}

// Amazon Linux optimized for ECS
// See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI_launch_latest.html
data "aws_ami" "aws_ecs" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
