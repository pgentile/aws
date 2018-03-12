resource "local_file" "ssh_config" {
  content  = "UserKnownHostsFile ${path.module}/output/known-hosts\n\n${join("\n\n", local.host_ssh_config)}\n\n${local.bastion_ssh_config}\n"
  filename = "output/ssh-config"
}

locals {
  bastion_public_ip = "${aws_eip.ssh_bastion.public_ip}"

  bastion_ssh_config = "${format(
    "Host bastion\n  HostName %s\n  User ec2-user\n  IdentityFile %s\n  ForwardAgent yes\n  AddKeysToAgent yes",
    local.bastion_public_ip,
    local_file.ssh_private_key.filename
  )}"

  host_ssh_config = "${formatlist(
    "Host %s\n  HostName %s\n  User ec2-user\n  IdentityFile %s\n  ProxyJump bastion",
    aws_instance.example.*.tags.Name,
    aws_instance.example.*.private_ip,
    local_file.ssh_private_key.filename
  )}"
}

output "ssh_connection_strings" {
  value = "${formatlist(
    "ssh -F %s %s",
    local_file.ssh_config.filename,
    aws_instance.example.*.tags.Name
  )}"
}
