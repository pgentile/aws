resource "aws_instance" "example" {
  count         = 2
  ami           = "${data.aws_ami.amazon_linux.id}"
  instance_type = "t2.micro"

  vpc_security_group_ids = [
    "${aws_vpc.example.default_security_group_id}",
    "${aws_security_group.ssh_external.id}",
    "${aws_security_group.http.id}",
  ]

  subnet_id                   = "${element(aws_subnet.public.*.id, count.index % aws_subnet.public.count)}"
  associate_public_ip_address = true
  key_name                    = "${aws_key_pair.ssh_key.key_name}"
  root_block_device {
    volume_size = 8
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y update",
      "sudo yum -y install nginx",
      "sudo service nginx start",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file("~/.ssh/id_rsa")}"
    }
  }

  tags        = "${merge(local.default_tags, map("Name", format("example-%03d", count.index + 1)))}"
  volume_tags = "${local.default_tags}"
}

resource "aws_instance" "private" {
  count         = 0
  ami           = "${data.aws_ami.amazon_linux.id}"
  instance_type = "t2.micro"

  vpc_security_group_ids = [
    "${aws_vpc.example.default_security_group_id}",
  ]

  subnet_id = "${element(aws_subnet.private.*.id, count.index % aws_subnet.private.count)}"
  key_name  = "${aws_key_pair.ssh_key.key_name}"

  root_block_device {
    volume_size = 8
  }

  tags        = "${merge(local.default_tags, map("Name", format("private-%03d", count.index + 1)))}"
  volume_tags = "${local.default_tags}"
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

output "example_ssh_connection_string" {
  description = "SSH connection string"
  value       = "${formatlist("ssh -o StrictHostKeyChecking=no ec2-user@%s", aws_instance.example.*.public_dns)}"
}

output "example_http_connection_string" {
  description = "HTTP connection string"
  value       = "${formatlist("http://%s", aws_instance.example.*.public_dns)}"
}
