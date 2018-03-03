data "aws_availability_zones" "availability_zones" {}

locals {
  availability_zones = "${sort(data.aws_availability_zones.availability_zones.names)}"
}
