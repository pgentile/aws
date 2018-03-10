locals {
  ssh_bastion_tags = "${merge(local.default_tags, map("Name", "ssh-bastion"))}"
}

resource "aws_eip" "ssh_bastion" {
  depends_on = ["aws_internet_gateway.example"]

  vpc = true

  tags = "${local.ssh_bastion_tags}"
}

resource "aws_network_interface" "ssh_bastion" {
  description = "Network interface for SSH bastion"
  subnet_id   = "${aws_subnet.public.0.id}"

  security_groups = [
    "${aws_vpc.example.default_security_group_id}",
    "${aws_security_group.ssh_bastion.id}",
  ]

  tags = "${local.ssh_bastion_tags}"
}

resource "aws_eip_association" "eip_assoc" {
  network_interface_id = "${aws_network_interface.ssh_bastion.id}"
  allocation_id        = "${aws_eip.ssh_bastion.id}"
}

resource "aws_instance" "ssh_bastion" {
  depends_on = ["aws_internet_gateway.example"]

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
