output "name" {
  description = "Group name"
  value       = "${var.name}"
}

output "autoscaling_group_id" {
  description = "Autoscaling group ID"
  value       = "${aws_autoscaling_group.this.id}"
}

output "launch_configuration_id" {
  description = "Launch configuration ID"
  value       = "${aws_launch_configuration.this.id}"
}
