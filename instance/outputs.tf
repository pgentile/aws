output "private_ip" {
  description = "Private IP"
  value       = "${aws_instance.this.private_ip}"
}

output "public_ip" {
  description = "Public IP"
  value       = "${aws_instance.this.public_ip}"
}

output "admin_username" {
  description = "Admin username"
  value       = "${module.instance_config.admin_username}"
}

output "name" {
  description = "Instance name"
  value       = "${var.name}"
}

output "id" {
  description = "Instance ID"
  value       = "${aws_instance.this.id}"
}
