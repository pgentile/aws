resource "local_file" "ssh_config" {
  content  = "${local.base_ssh_config}\n\n${local.any_host_ssh_config}\n"
  filename = "${path.module}/output/ssh/config"

  file_permission      = "0644"
  directory_permission = "0755"
}

locals {
  base_ssh_config = format(
    "IdentityFile %s\nUserKnownHostsFile %s\nStrictHostKeyChecking accept-new\nAddKeysToAgent yes",
    abspath(local_file.ssh_private_key.filename),
    abspath("${path.module}/output/ssh/known-hosts"),
  )

  any_host_ssh_config = "Host *.compute.amazonaws.com\n  User core"
}

resource "local_file" "ssh_private_key" {
  content  = tls_private_key.ssh.private_key_pem
  filename = "${path.module}/output/ssh/private-key"

  file_permission      = "0600"
  directory_permission = "0755"
}

resource "local_file" "ssh_public_key" {
  content  = tls_private_key.ssh.public_key_openssh
  filename = "${path.module}/output/ssh/public-key"

  file_permission      = "0644"
  directory_permission = "0755"
}

output "ssh_connection_string" {
  value = format("ssh -F %s HOST", abspath(local_file.ssh_config.filename))
}
