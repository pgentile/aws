// The CoreOS instance

locals {
  coreos_instance_tags = merge(
    local.platform_tags,
    {
      "Name" = "coreos"
    },
  )

  ignition_json_filename = "${path.module}/output/coreos/ignition.json"
}

resource "aws_instance" "coreos" {
  count         = 1
  ami           = data.aws_ami.coreos.id
  instance_type = "t2.micro"

  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibility in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  vpc_security_group_ids = [module.base_security_group.id]

  associate_public_ip_address = true

  subnet_id = module.network.subnet_ids[count.index]
  key_name  = aws_key_pair.ssh.key_name
  user_data = data.ct_config.ignition_config.rendered

  iam_instance_profile = aws_iam_instance_profile.coreos.name

  root_block_device {
    volume_size = 8
  }

  tags        = local.coreos_instance_tags
  volume_tags = local.coreos_instance_tags
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

data "template_file" "ignition_config" {
  template = file("${path.module}/coreos-config.yaml.tpl")

  vars = {
    env                         = var.env
    platform                    = var.platform
    region                      = var.region
    etcd_discovery_token        = var.etcd_discovery_token
    cluster_name                = aws_ecs_cluster.default.name
    flannel_cidr_block          = var.flannel_cidr_block
    docker_cloudwatch_log_group = aws_cloudwatch_log_group.docker_logs.name
  }
}

// Don't forget to install the script. See the install-terraform-plugins.sh script
data "ct_config" "ignition_config" {
  content      = data.template_file.ignition_config.rendered
  platform     = "ec2"
  pretty_print = true
}

resource "local_file" "ignition_config" {
  content              = data.ct_config.ignition_config.rendered
  filename             = local.ignition_json_filename
  file_permission      = "0644"
  directory_permission = "0755"
}

// Instance profile

resource "aws_iam_instance_profile" "coreos" {
  name = "coreos"
  role = aws_iam_role.coreos.name
}

resource "aws_iam_role" "coreos" {
  name               = "coreos"
  description        = "CoreOS role"
  assume_role_policy = data.aws_iam_policy_document.coreos.json
}

data "aws_iam_policy_document" "coreos" {
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

  policy = data.aws_iam_policy_document.publish_cloudwatch_logs.json
}

data "aws_iam_policy_document" "publish_cloudwatch_logs" {
  statement {
    effect    = "Allow"
    resources = ["arn:aws:logs:${var.region}:*"]

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "publish_cloudwatch_logs" {
  role       = aws_iam_role.coreos.name
  policy_arn = aws_iam_policy.publish_cloudwatch_logs.arn
}

// Access to storage for the  REX-Ray Docker plugin, that provides EBS volumes
// See https://rexray.readthedocs.io/en/stable/user-guide/storage-providers/aws/

resource "aws_iam_policy" "access_ebs_rex_ray" {
  name        = "access-ebs-rex-ray"
  description = "Access EBS for the REX-Ray Docker plugin"

  policy = data.aws_iam_policy_document.access_ebs_rex_ray.json
}

data "aws_iam_policy_document" "access_ebs_rex_ray" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInstances",
      "ec2:DescribeVolumes",
      "ec2:DescribeVolumeAttribute",
      "ec2:DescribeVolumeStatus",
      "ec2:DescribeTags",
      "ec2:ModifyVolumeAttribute",
    ]
  }

  statement {
    effect = "Allow"

    resources = [
      "*",
      "arn:aws:ec2:${var.region}::volume/*",
      "arn:aws:ec2:${var.region}::instance/*",
    ]

    actions = [
      "ec2:AttachVolume",
      "ec2:CreateVolume",
      "ec2:CreateTags",
      "ec2:DeleteVolume",
      "ec2:DetachVolume",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "access_ebs_rex_ray" {
  role       = aws_iam_role.coreos.name
  policy_arn = aws_iam_policy.access_ebs_rex_ray.arn
}

// Access to ECS from EC2

resource "aws_iam_role_policy_attachment" "ecs" {
  role       = aws_iam_role.coreos.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

// Outputs

output "coreos_ami_id" {
  description = "ID of the CoreOS AMI"
  value       = data.aws_ami.coreos.id
}

output "etcd_discovery_token" {
  description = "etcd discovery token for CoreOS instance"
  value       = var.etcd_discovery_token
}

output "coreos_public_dns" {
  description = "CoreOS public DNS"
  value       = [aws_instance.coreos.*.public_dns]
}

output "ignition_json_filename" {
  description = "Ignition JSON config filename"
  value       = local.ignition_json_filename
}

