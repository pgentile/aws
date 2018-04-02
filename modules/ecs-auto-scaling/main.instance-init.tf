resource "aws_launch_configuration" "this" {
  name_prefix          = "${var.name}-"
  instance_type        = "t2.micro"
  image_id             = "${data.aws_ami.aws_ecs.id}"
  iam_instance_profile = "${aws_iam_instance_profile.ecs.id}"
  key_name             = "${var.key_name}"
  security_groups      = ["${var.security_group_ids}"]

  associate_public_ip_address = "${var.associate_public_ip_address}"

  user_data = "${data.template_file.cloud_init.rendered}"

  // C'est payant, le monitoring avancé... Alors, on le coupe !
  enable_monitoring = false

  // Root device
  root_block_device {
    volume_size = 8
  }

  // Volume used by Docker devicemapper
  ebs_block_device {
    device_name = "/dev/xvdcz"
    volume_size = 22
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "cloud_init" {
  template = "${file("${path.module}/instance-init/cloud-init.yaml.tpl")}"

  vars {
    name                = "${var.name}"
    instance_script_url = "http://${var.instance_config_s3_domain_name}/${aws_s3_bucket_object.configure_instance_script.key}"
  }
}

resource "aws_s3_bucket_object" "configure_instance_script" {
  bucket       = "${var.instance_config_s3_bucket_id}"
  key          = "instance-init/${var.name}/configure-instance.sh"
  content      = "${file("${path.module}/instance-init/configure-instance.sh")}"
  content_type = "text/plain"

  // FIXME : trouver la bonne combinaison d'ACL sur S3...
  acl = "public-read"

  tags = "${var.tags}"
}

// Amazon Linux optimized for ECS
// See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI_launch_latest.html
data "aws_ami" "aws_ecs" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
