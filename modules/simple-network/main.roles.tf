resource "aws_iam_role" "flow_logs" {
  name               = "${var.name}-flow-logs"
  description        = "Flow logs for VPC ${var.name}"
  assume_role_policy = "${data.aws_iam_policy_document.assume_flow_logs.json}"
}

data "aws_iam_policy_document" "assume_flow_logs" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "publish_flow_logs" {
  name        = "${var.name}-publish-vpc-flow-logs"
  description = "Publish logs of VPC ${var.name} to Cloudwatch"

  policy = "${data.aws_iam_policy_document.publish_flow_logs.json}"
}

// The role logs:CreateLogGroup is removed.
// Only the admin shoud create new log groups.
// arn:aws:logs:region:*:* ???
data "aws_iam_policy_document" "publish_flow_logs" {
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

resource "aws_iam_role_policy_attachment" "publish_flow_logs" {
  role       = "${aws_iam_role.flow_logs.name}"
  policy_arn = "${aws_iam_policy.publish_flow_logs.arn}"
}
