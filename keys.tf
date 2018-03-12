resource "aws_key_pair" "ssh" {
  key_name   = "ssh"
  public_key = "${tls_private_key.ssh.public_key_openssh}"
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "ssh_private_key" {
  content  = "${tls_private_key.ssh.private_key_pem}"
  filename = "${path.module}/output/ssh-private-key"
}

resource "local_file" "ssh_public_key" {
  content  = "${tls_private_key.ssh.public_key_openssh}"
  filename = "${path.module}/output/ssh-public-key"
}
