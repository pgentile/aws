// The CoreOS instance

locals {
  coreos_instance_tags = "${merge(local.platform_tags, map("Name", "coreos"))}"
}

resource "aws_instance" "coreos" {
  ami           = "${data.aws_ami.coreos.id}"
  instance_type = "t2.micro"

  vpc_security_group_ids = ["${module.base_security_group.id}"]

  associate_public_ip_address = true

  subnet_id = "${module.network.subnet_ids[0]}"
  key_name  = "${aws_key_pair.ssh.key_name}"
  user_data = "${data.ct_config.ignition_config.rendered}"

  iam_instance_profile = "${aws_iam_instance_profile.coreos.name}"

  root_block_device {
    volume_size = 8
  }

  tags        = "${local.coreos_instance_tags}"
  volume_tags = "${local.coreos_instance_tags}"
}

// Search CoreOS AMI

// CoreOS
// See https://coreos.com/os/docs/latest/booting-on-ec2.html
data "aws_ami" "coreos" {
  most_recent = true

  # CoreOS AWS account number
  owners = [595879546273]

  filter {
    name   = "name"
    values = ["CoreOS-stable-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

// CoreOS Ignition config (convert from the YAML template to JSON with the ct command)
// Don't forget to install the ct command (brew instann coreos-ct on MacOS)

data "template_file" "ignition_config" {
  template = "${file("${path.module}/coreos-config.yaml.tpl")}"

  vars {
    env                  = "${var.env}"
    platform             = "${var.platform}"
    region               = "${var.region}"
    etcd_discovery_token = "${var.etcd_discovery_token}"
  }
}

// Don't forget to install the script. See the install-terraform-plugins.sh script
data "ct_config" "ignition_config" {
  content      = "${data.template_file.ignition_config.rendered}"
  platform     = "ec2"
  pretty_print = false
}

resource "local_file" "ignition_config" {
  content  = "${data.ct_config.ignition_config.rendered}"
  filename = "${path.module}/output/coreos/ignition.json"
}

// Instance profile

resource "aws_iam_instance_profile" "coreos" {
  name = "coreos"
  role = "${aws_iam_role.coreos.name}"
}

resource "aws_iam_role" "coreos" {
  name               = "coreos"
  description        = "CoreOS role"
  assume_role_policy = "${data.aws_iam_policy_document.assume_ec2.json}"
}

data "aws_iam_policy_document" "assume_ec2" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

// Publish Cloudwatch logs

resource "aws_iam_policy" "publish_cloudwatch_logs" {
  name        = "publish-cloudwatch-logs"
  description = "Publish logs to Cloudwatch"

  policy = "${data.aws_iam_policy_document.publish_cloudwatch_logs.json}"
}

data "aws_iam_policy_document" "publish_cloudwatch_logs" {
  statement {
    effect    = "Allow"
    resources = ["arn:aws:logs:${var.region}:*:*"]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "publish_cloudwatch_logs" {
  role       = "${aws_iam_role.coreos.name}"
  policy_arn = "${aws_iam_policy.publish_cloudwatch_logs.arn}"
}

// Access to ECS from EC2

resource "aws_iam_role_policy_attachment" "ecs" {
  role       = "${aws_iam_role.coreos.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

// Outputs

output "coreos_ami_id" {
  description = "ID of the CoreOS AMI"
  value       = "${data.aws_ami.coreos.id}"
}

output "etcd_discovery_token" {
  description = "etcd discovery token for CoreOS instance"
  value       = "${var.etcd_discovery_token}"
}

output "coreos_public_ip" {
  description = "CoreOS public IP"
  value       = "${aws_instance.coreos.public_ip}"
}
