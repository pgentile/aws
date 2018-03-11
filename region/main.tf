data "aws_region" "this" {}

module "network" {
  source = "./vpc"

  name       = "${var.name}"
  cidr_block = "${var.cidr_block}"

  public_availability_zones = "${var.public_availability_zones}"
  public_cidr_blocks        = ["${var.public_cidr_blocks}"]

  private_availability_zones = "${var.private_availability_zones}"
  private_cidr_blocks        = ["${var.private_cidr_blocks}"]

  database_availability_zones = "${var.database_availability_zones}"
  database_cidr_blocks        = ["${var.database_cidr_blocks}"]

  tags = "${var.tags}"
}
