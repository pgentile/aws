data "aws_region" "this" {}

module "network" {
  source = "./vpc"

  name       = "${var.name}"
  cidr_block = "${var.cidr_block}"

  public_cidr_blocks   = ["${var.public_cidr_blocks}"]
  private_cidr_blocks  = ["${var.private_cidr_blocks}"]
  database_cidr_blocks = ["${var.database_cidr_blocks}"]

  tags = "${var.tags}"
}
