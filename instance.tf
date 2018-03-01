resource "aws_instance" "example" {
  count         = 1
  ami           = "${data.aws_ami.amazon_linux.id}"
  instance_type = "t2.micro"

  availability_zone           = "${var.aws_default_availability_zone}"
  key_name                    = "${aws_key_pair.ssh_key.key_name}"
  associate_public_ip_address = true

  tags {
    Name        = "Terraform"
    Provisioner = "terraform"
  }

  root_block_device {
    volume_size = 8
  }
}

resource "aws_route53_record" "example" {
  zone_id = "${aws_route53_zone.vpc_zone.zone_id}"
  name    = "dev.${aws_route53_zone.vpc_zone.name}"
  type    = "A"
  ttl     = "30"

  records = [
    "${aws_instance.example.private_ip}",
  ]
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name = "name"

    # values = ["amzn-ami-*-x86_64-gp2"]
    values = [
      "amzn-ami-2017.09.*-amazon-ecs-optimized",
    ]
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

resource "aws_key_pair" "ssh_key" {
  key_name   = "ssh_key"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}
