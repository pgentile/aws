resource "local_file" "ssh_config" {
  content  = "${local.base_ssh_config}\n\n${local.any_host_ssh_config}\n"
  filename = "${path.module}/output/ssh/config"
}

locals {
  base_ssh_config = "${format(
    "IdentityFile %s\nUserKnownHostsFile %s\nStrictHostKeyChecking accept-new\nAddKeysToAgent yes",
    local_file.ssh_private_key.filename,
    "${path.module}/output/ssh/known-hosts"
  )}"

  any_host_ssh_config = "Host *.compute.amazonaws.com\n  User core"
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

output "ssh_connection_string" {
  value = "${format(
    "ssh -F %s HOST",
    local_file.ssh_config.filename
  )}"
}
