resource "local_file" "ssh_config" {
  content  = "${local.base_ssh_config}\n\n${join("\n\n", local.host_ssh_config)}\n\n${local.bastion_ssh_config}\n"
  filename = "${path.module}/output/ssh/config"
}

locals {
  base_ssh_config = "${format(
    "IdentityFile %s\nUserKnownHostsFile %s",
    local_file.ssh_private_key.filename,
    "${path.module}/output/ssh/known-hosts"
  )}"

  bastion_ssh_config = "${format(
    "Host bastion\n  HostName %s\n  User %s\n  ForwardAgent yes\n  AddKeysToAgent yes",
    module.ssh_bastion.public_ip,
    module.ssh_bastion.admin_username
  )}"

  host_ssh_config = "${formatlist(
    "Host %s\n  HostName %s\n  User %s\n  ProxyJump bastion",
    list(module.example_instance.name),
    list(module.example_instance.private_ip),
    list(module.example_instance.admin_username)
  )}"
}

resource "local_file" "ssh_private_key" {
  content  = "${tls_private_key.ssh.private_key_pem}"
  filename = "${path.module}/output/ssh/private-key"

  // The SSH key must be readable only for the current user
  provisioner "local-exec" {
    command = "chmod og-rwx ${self.filename}"
  }
}

resource "local_file" "ssh_public_key" {
  content  = "${tls_private_key.ssh.public_key_openssh}"
  filename = "${path.module}/output/ssh/public-key"
}

output "ssh_connection_strings" {
  value = "${formatlist(
    "ssh -F %s %s",
    local_file.ssh_config.filename,
    list(module.example_instance.name)
  )}"
}
