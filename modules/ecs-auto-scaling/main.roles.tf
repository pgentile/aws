resource "aws_iam_instance_profile" "ecs" {
  name = "${var.name}-ecs"
  role = "${aws_iam_role.ecs.name}"
}

resource "aws_iam_role" "ecs" {
  name               = "${var.name}-ecs"
  description        = "ECS instance role for ${var.name}"
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
  name        = "${var.name}-publish-cloudwatch-logs"
  description = "Publish logs to Cloudwatch"

  policy = "${data.aws_iam_policy_document.publish_cloudwatch_logs.json}"
}

// The role logs:CreateLogGroup is removed.
// Only the admin shoud create new log groups.
data "aws_iam_policy_document" "publish_cloudwatch_logs" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "publish_cloudwatch_logs" {
  role       = "${aws_iam_role.ecs.name}"
  policy_arn = "${aws_iam_policy.publish_cloudwatch_logs.arn}"
}

// Access to the S3 bucket that contains scripts

/*
resource "aws_iam_policy" "access_instance_config_s3" {
  name        = "${var.name}-access-instance-config-s3"
  description = "Access the S3 that contains instance config of ${var.name}"

  policy = "${data.aws_iam_policy_document.access_instance_config_s3.json}"
}

data "aws_iam_policy_document" "access_instance_config_s3" {
  statement {
    effect    = "Allow"
    resources = ["${var.instance_config_s3_bucket_arn}"]
    actions   = ["s3:List*"]
  }

  statement {
    effect    = "Allow"
    resources = ["${var.instance_config_s3_bucket_arn}/*"]
    actions   = ["s3:Get*"]
  }
}

resource "aws_iam_role_policy_attachment" "access_instance_config_s3" {
  role       = "${aws_iam_role.ecs.name}"
  policy_arn = "${aws_iam_policy.access_instance_config_s3.arn}"
}
*/

// Access to ECS from EC2

resource "aws_iam_role_policy_attachment" "ecs" {
  role       = "${aws_iam_role.ecs.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}
