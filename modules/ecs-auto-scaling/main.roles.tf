resource "aws_iam_instance_profile" "ecs" {
  name = "${var.name}-ecs"
  role = aws_iam_role.ecs.name
}

resource "aws_iam_role" "ecs" {
  name               = "${var.name}-ecs"
  description        = "ECS instance role for ${var.name}"
  assume_role_policy = data.aws_iam_policy_document.assume_ec2.json
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

  policy = data.aws_iam_policy_document.publish_cloudwatch_logs.json
}

data "aws_iam_policy_document" "publish_cloudwatch_logs" {
  statement {
    effect    = "Allow"
    resources = ["*"]

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
  role       = aws_iam_role.ecs.name
  policy_arn = aws_iam_policy.publish_cloudwatch_logs.arn
}

// Access to ECS from EC2

resource "aws_iam_role_policy_attachment" "ecs" {
  role       = aws_iam_role.ecs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}
