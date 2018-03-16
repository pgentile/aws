locals {
  ssh_bastion_tags = "${merge(local.default_tags, map("Name", "ssh-bastion"))}"
}

module "ssh_bastion" {
  source = "./instance"

  name      = "ssh-bastion"
  key_name  = "${aws_key_pair.ssh.key_name}"
  subnet_id = "${aws_subnet.public.*.id[0]}"

  vpc_security_group_ids = [
    "${aws_vpc.example.default_security_group_id}",
    "${aws_security_group.ssh_bastion.id}",
  ]

  tags = "${local.default_tags}"
}

output "bastion_ssh_connection_string" {
  description = "Bastion SSH connection string"
  value       = "${format("ssh -A -o StrictHostKeyChecking=no admin@%s", module.ssh_bastion.public_ip)}"
}

output "bastion_public_ip" {
  value = "${module.ssh_bastion.public_ip}"
}
