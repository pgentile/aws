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

output "instance_private_ips" {
  description = "Instance private IPs"
  value       = ["${data.aws_instances.this.private_ips}"]
}

output "instance_admin_username" {
  description = "Admin username of instances"
  value       = "${module.instance_config.admin_username}"
}
