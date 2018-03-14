resource "aws_instance" "example" {
  depends_on = ["aws_internet_gateway.example", "aws_instance.ssh_bastion"]

  count = 1

  ami           = "${data.aws_ami.debian.id}"
  instance_type = "t2.micro"

  vpc_security_group_ids = [
    "${aws_vpc.example.default_security_group_id}",
    "${aws_security_group.http_server.id}",
  ]

  // Normalement, on ne devrait pas faire ça, mais bon...
  // On ne va pas payer pour un Gatway NAT !
  // Ou alors, il nous faudrait une NAT instance
  // Si on n'a pas d'IP public, par contre, impossible de sortir sur Internet
  associate_public_ip_address = true

  subnet_id = "${element(aws_subnet.public.*.id, count.index % aws_subnet.public.count)}"
  key_name  = "${aws_key_pair.ssh.key_name}"
  user_data = "${file("./instance-init.sh")}"

  root_block_device {
    volume_size = 8
  }

  connection {
    type        = "ssh"
    host        = "${self.private_ip}"
    user        = "admin"
    private_key = "${tls_private_key.ssh.private_key_pem}"

    bastion_host = "${aws_eip.ssh_bastion.public_ip}"
  }

  tags        = "${merge(local.default_tags, map("Name", format("example-%03d", count.index + 1)))}"
  volume_tags = "${local.default_tags}"
}

output "example_private_ip" {
  description = "Example private IP"
  value       = "${aws_instance.example.*.private_ip}"
}

output "example_http_connection_string" {
  description = "HTTP connection string"
  value       = "${formatlist("http://%s", aws_instance.example.*.public_dns)}"
}
