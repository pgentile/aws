output "ami_id" {
  description = "AMI ID"
  value       = "${data.aws_ami.debian.id}"
}

output "user_data" {
  description = "User data to launch the instance"
  value       = "${data.template_file.cloud_init.rendered}"
}

output "admin_username" {
  description = "Admin username"
  value       = "admin"
}
