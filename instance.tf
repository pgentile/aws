resource "aws_instance" "example" {
  depends_on = ["aws_instance.ssh_bastion"]

  count = 1

  ami           = "${data.aws_ami.amazon_linux.id}"
  instance_type = "t2.micro"

  vpc_security_group_ids = [
    "${module.vpc.default_security_group_id}",
  ]

  // Normalement, on ne devrait pas faire ça, mais bon...
  // On ne va pas payer pour un Gatway NAT !
  // Ou alors, il nous faudrait une NAT instance
  associate_public_ip_address = true

  subnet_id = "${element(module.vpc.public_subnets, count.index % length(module.vpc.public_subnets))}"
  key_name  = "${aws_key_pair.ssh_key.key_name}"

  root_block_device {
    volume_size = 8
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y update",
      "sudo yum-config-manager --enable epel",
      "sudo yum -y install ansible",
      "sudo yum -y install nginx",
      "sudo service nginx start",
    ]

    connection {
      type        = "ssh"
      host        = "${self.private_ip}"
      user        = "ec2-user"
      private_key = "${file("${var.ssh_private_key_file}")}"

      bastion_host = "${aws_eip.ssh_bastion.0.public_ip}"
    }
  }

  tags        = "${merge(local.default_tags, map("Name", format("example-%03d", count.index + 1)))}"
  volume_tags = "${local.default_tags}"
}

output "example_private_ip" {
  description = "Example private IP"
  value       = "${aws_instance.example.*.private_ip}"
}

output "example_ssh_connection_string" {
  description = "Bastion SSH connection string"
  value       = "${formatlist("ssh -t -A -o StrictHostKeyChecking=no ec2-user@%s ssh %s", aws_eip.ssh_bastion.0.public_ip, aws_instance.example.*.private_ip)}"
}

output "example_http_connection_string" {
  description = "HTTP connection string"
  value       = "${formatlist("http://%s", aws_instance.example.*.public_dns)}"
}
