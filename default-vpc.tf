resource "aws_default_vpc" "default" {
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name        = "DEFAULT"
    Provisioner = "terraform"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = "${aws_default_vpc.default.id}"

  ingress {
    description = "SSH"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["${var.my_ip}/32"]
  }

  ingress {
    description = "HTTP"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "ALL"
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "DEFAULT"
    Provisioner = "terraform"
  }
}

resource "aws_default_route_table" "route_table" {
  default_route_table_id = "${aws_default_vpc.default.default_route_table_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags {
    Name        = "DEFAULT"
    Provisioner = "terraform"
  }
}

resource "aws_default_subnet" "default" {
  count             = "${length(local.availability_zones)}"
  availability_zone = "${element(local.availability_zones, count.index)}"

  tags {
    Name        = "DEFAULT / ${element(local.availability_zones, count.index)}"
    Provisioner = "terraform"
  }
}

resource "aws_default_network_acl" "default" {
  default_network_acl_id = "${aws_default_vpc.default.default_network_acl_id}"

  ingress {
    protocol   = "tcp"
    rule_no    = 1000
    action     = "allow"
    cidr_block = "${var.my_ip}/32"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 1001
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 2000
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = -1
    rule_no    = 9999
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "tcp"
    rule_no    = 1000
    action     = "allow"
    cidr_block = "${var.my_ip}/32"
    from_port  = 22
    to_port    = 22
  }

  egress {
    protocol   = "tcp"
    rule_no    = 1001
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  egress {
    protocol   = -1
    rule_no    = 9999
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags {
    Name        = "DEFAULT"
    Provisioner = "terraform"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_default_vpc.default.id}"

  tags {
    Name        = "DEFAULT"
    Provisioner = "terraform"
  }
}

resource "aws_default_vpc_dhcp_options" "default" {
  tags {
    Name        = "DEFAULT"
    Provisioner = "terraform"
  }
}

resource "aws_flow_log" "default_vpc" {
  log_group_name = "${aws_cloudwatch_log_group.default_vpc.name}"
  iam_role_arn   = "${aws_iam_role.default_vpc_flow_log.arn}"
  vpc_id         = "${aws_default_vpc.default.id}"
  traffic_type   = "ALL"
}

resource "aws_cloudwatch_log_group" "default_vpc" {
  name = "DefaultVPC"

  tags {
    Provisioner = "terraform"
  }
}

resource "aws_iam_role" "default_vpc_flow_log" {
  name = "DefaultVPCFlowLogRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "default_vpc_flow_log" {
  name = "DefaultVPCFlowLogPolicy"
  role = "${aws_iam_role.default_vpc_flow_log.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
