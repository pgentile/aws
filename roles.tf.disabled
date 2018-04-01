resource "aws_iam_policy" "read_public_ssh_keys" {
  name        = "read-public-ssh-keys"
  description = "Read public SSH keys of all users in IAM"

  policy = "${data.aws_iam_policy_document.read_public_ssh_keys.json}"
}

data "aws_iam_policy_document" "read_public_ssh_keys" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "iam:ListSSHPublicKeys",
      "iam:GetSSHPublicKey",
    ]
  }
}

resource "aws_iam_policy" "publish_cloudwatch_logs" {
  name        = "publish-cloudwatch-logs"
  description = "Publish logs to Cloudwatch"

  policy = "${data.aws_iam_policy_document.publish_cloudwatch_logs.json}"
}

data "aws_iam_policy_document" "publish_cloudwatch_logs" {
  statement {
    effect    = "Allow"
    resources = ["arn:aws:logs:*:*:*"]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]
  }
}

resource "aws_iam_role" "ec2" {
  name               = "ec2"
  description        = "EC2 instances roles"
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

resource "aws_iam_role_policy_attachment" "ec2_read_public_ssh_keys" {
  role       = "${aws_iam_role.ec2.name}"
  policy_arn = "${aws_iam_policy.read_public_ssh_keys.arn}"
}

resource "aws_iam_role_policy_attachment" "ec2_publish_cloudwatch_logs" {
  role       = "${aws_iam_role.ec2.name}"
  policy_arn = "${aws_iam_policy.publish_cloudwatch_logs.arn}"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "ec2"
  role = "${aws_iam_role.ec2.name}"
}
