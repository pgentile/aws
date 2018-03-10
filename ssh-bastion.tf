locals {
  ssh_bastion_tags = "${merge(local.default_tags, map("Name", "ssh-bastion"))}"

  // bastion_count = "${length(module.vpc.public_subnets)}"
  bastion_count = 1
}

resource "aws_eip" "ssh_bastion" {
  depends_on = ["module.vpc"]
  count      = "${local.bastion_count}"

  vpc = true

  tags = "${local.ssh_bastion_tags}"
}

resource "aws_network_interface" "ssh_bastion" {
  count       = "${local.bastion_count}"
  description = "Network interface for SSH bastion"
  subnet_id   = "${element(module.vpc.public_subnets, count.index)}"

  security_groups = [
    "${module.vpc.default_security_group_id}",
    "${module.ssh_bastion_sg.this_security_group_id}",
  ]

  tags = "${local.ssh_bastion_tags}"
}

resource "aws_eip_association" "ssh_bastion" {
  count                = "${local.bastion_count}"
  network_interface_id = "${element(aws_network_interface.ssh_bastion.*.id, count.index)}"
  allocation_id        = "${element(aws_eip.ssh_bastion.*.id, count.index)}"
}

resource "aws_instance" "ssh_bastion" {
  count = "${local.bastion_count}"

  ami           = "${data.aws_ami.amazon_linux.id}"
  instance_type = "t2.micro"

  key_name = "${aws_key_pair.ssh_key.key_name}"

  root_block_device {
    volume_size = 8
  }

  network_interface {
    network_interface_id = "${element(aws_network_interface.ssh_bastion.*.id, count.index)}"
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
      host        = "${element(aws_eip.ssh_bastion.*.public_ip, count.index)}"
      user        = "ec2-user"
      private_key = "${file("${var.ssh_private_key_file}")}"
    }
  }

  tags        = "${local.ssh_bastion_tags}"
  volume_tags = "${local.ssh_bastion_tags}"
}

output "bastion_ssh_connection_string" {
  description = "Bastion SSH connection string"
  value       = "${formatlist("ssh -A -o StrictHostKeyChecking=no ec2-user@%s", aws_eip.ssh_bastion.*.public_ip)}"
}
