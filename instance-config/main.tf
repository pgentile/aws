data "template_file" "cloud_init" {
  template = "${file("${path.module}/cloud-init.yaml.tpl")}"

  vars {
    hostname                   = "${var.hostname}"
    ssh_allow_tcp_forwarding   = "${var.ssh_allow_tcp_forwarding}"
    ssh_allow_agent_forwarding = "${var.ssh_allow_agent_forwarding}"
  }
}

// See the Debian doc: https://wiki.debian.org/Cloud/AmazonEC2Image/Stretch
data "aws_ami" "debian" {
  most_recent = true

  owners = ["379101102735"]

  filter {
    name   = "name"
    values = ["debian-stretch-hvm-x86_64-gp2-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
