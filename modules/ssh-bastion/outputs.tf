output "private_ip" {
  description = "Private IP"
  value       = "${module.instance.private_ip}"
}

output "public_ip" {
  description = "Public IP"
  value       = "${module.instance.public_ip}"
}

output "admin_username" {
  description = "Admin username"
  value       = "admin"
}

output "name" {
  description = "Instance name"
  value       = "${var.name}"
}

output "id" {
  description = "Instance ID"
  value       = "${module.instance.id}"
}
