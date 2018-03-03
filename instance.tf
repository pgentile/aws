resource "aws_instance" "example" {
  count         = 1
  ami           = "${data.aws_ami.amazon_linux.id}"
  instance_type = "t2.micro"

  availability_zone           = "${element(local.availability_zones, count.index % length(local.availability_zones))}"
  key_name                    = "${aws_key_pair.ssh_key.key_name}"
  associate_public_ip_address = true

  tags {
    Name        = "${format("example-%03d", count.index + 1)}"
    Provisioner = "terraform"
  }

  volume_tags {
    Name        = "Terraform"
    Provisioner = "terraform"
  }

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
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name = "name"

    // ECS AMI : amzn-ami-2017.09.*-amazon-ecs-optimized
    values = [
      "amzn-ami-*-x86_64-gp2",
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

resource "aws_lb" "example" {
  name            = "TerraformLB"
  subnets         = ["${aws_default_subnet.default.*.id}"]
  security_groups = ["${aws_default_security_group.default.id}"]

  tags {
    Provisioner = "terraform"
  }
}

resource "aws_lb_listener" "example_http" {
  load_balancer_arn = "${aws_lb.example.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.backend.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "backend" {
  name     = "TerraformLBBackend"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_default_vpc.default.id}"

  tags {
    Provisioner = "terraform"
  }
}

resource "aws_lb_target_group_attachment" "example" {
  count            = "${aws_instance.example.count}"
  target_group_arn = "${aws_lb_target_group.backend.arn}"
  target_id        = "${element(aws_instance.example.*.id, count.index)}"
  port             = 80
}

output "example_lb_url" {
  description = "Example load balancer URL"
  value       = "http://${aws_lb.example.dns_name}"
}

output "example_ssh_connection_string" {
  description = "SSH connection string"
  value       = "${formatlist("ssh -o StrictHostKeyChecking=no ec2-user@%s", aws_instance.example.*.public_dns)}"
}
