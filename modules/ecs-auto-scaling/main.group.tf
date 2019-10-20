locals {
  tags       = merge(var.tags, map("AutoscalingGroup", var.name))
  tag_keys   = keys(local.tags)
  tag_values = values(local.tags)
}

// We use the null_data_source to create the tag list from the map
// The tags will be propagated to the instance
data "null_data_source" "propagated_tags" {
  count = length(local.tags)

  inputs = {
    key                 = local.tag_keys[count.index]
    value               = local.tag_values[count.index]
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "this" {
  name_prefix          = "${var.name}-"
  launch_configuration = aws_launch_configuration.this.name
  vpc_zone_identifier  = [var.subnet_ids]

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

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
