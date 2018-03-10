locals {
  ssh_bastion_tags = "${merge(local.default_tags, map("Name", "ssh-bastion"))}"
}

resource "aws_eip" "ssh_bastion" {
  depends_on = ["module.vpc"]

  vpc = true

  tags = "${local.ssh_bastion_tags}"
}

resource "aws_network_interface" "ssh_bastion" {
  description = "Network interface for SSH bastion"
  subnet_id   = "${module.vpc.public_subnets[0]}"

  security_groups = [
    "${module.vpc.default_security_group_id}",
    "${module.ssh_bastion_sg.this_security_group_id}",
  ]

  tags = "${local.ssh_bastion_tags}"
}

resource "aws_eip_association" "ssh_bastion" {
  network_interface_id = "${aws_network_interface.ssh_bastion.id}"
  allocation_id        = "${aws_eip.ssh_bastion.id}"
}

resource "aws_instance" "ssh_bastion" {
  ami           = "${data.aws_ami.amazon_linux.id}"
  instance_type = "t2.micro"

  key_name = "${aws_key_pair.ssh_key.key_name}"

  root_block_device {
    volume_size = 8
  }

  network_interface {
    network_interface_id = "${aws_network_interface.ssh_bastion.id}"
    device_index         = 0
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y update",
      "sudo yum-config-manager --enable epel",
      "sudo yum -y install ansible",
    ]

    connection {
      type        = "ssh"
      host        = "${aws_eip.ssh_bastion.public_ip}"
      user        = "ec2-user"
      private_key = "${file("${var.ssh_private_key_file}")}"
    }
  }

  tags        = "${local.ssh_bastion_tags}"
  volume_tags = "${local.ssh_bastion_tags}"
}

output "bastion_ssh_connection_string" {
  description = "Bastion SSH connection string"
  value       = "${format("ssh -A -o StrictHostKeyChecking=no ec2-user@%s", aws_eip.ssh_bastion.public_ip)}"
}
