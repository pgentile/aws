module "primary" {
  source = "./region"

  name       = "primary"
  cidr_block = "${local.primary_cidr_block}"

  ssh_private_key_file = "${var.ssh_private_key_file}"
  ssh_public_key_file  = "${var.ssh_public_key_file}"

  public_availability_zones = ["${local.primary_availability_zones}"]

  public_cidr_blocks = [
    "${cidrsubnet(local.primary_cidr_block, 3, 0)}",
    "${cidrsubnet(local.primary_cidr_block, 3, 1)}",
  ]

  database_availability_zones = ["${local.primary_database_availability_zones}"]

  database_cidr_blocks = [
    "${cidrsubnet(local.primary_cidr_block, 3, 2)}",
    "${cidrsubnet(local.primary_cidr_block, 3, 3)}",
    "${cidrsubnet(local.primary_cidr_block, 3, 4)}",
  ]

  tags = "${local.tags}"
}

module "secondary" {
  source = "./region"

  providers = {
    aws = "aws.secondary"
  }

  name       = "secondary"
  cidr_block = "${local.secondary_cidr_block}"

  ssh_private_key_file = "${var.ssh_private_key_file}"
  ssh_public_key_file  = "${var.ssh_public_key_file}"

  public_availability_zones = ["${local.secondary_availability_zones}"]

  public_cidr_blocks = [
    "${cidrsubnet(local.secondary_cidr_block, 3, 0)}",
    "${cidrsubnet(local.secondary_cidr_block, 3, 1)}",
  ]

  database_availability_zones = ["${local.secondary_database_availability_zones}"]

  database_cidr_blocks = [
    "${cidrsubnet(local.secondary_cidr_block, 3, 2)}",
    "${cidrsubnet(local.secondary_cidr_block, 3, 3)}",
  ]

  tags = "${local.tags}"
}

resource "aws_vpc_peering_connection" "peer" {
  vpc_id      = "${module.primary.vpc_id}"
  peer_vpc_id = "${module.secondary.vpc_id}"
  peer_region = "${module.secondary.region}"
  auto_accept = false

  /*
  // This doesn't work for inter-region VPC

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }
  */

  tags = "${local.tags}"
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  provider = "aws.secondary"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.peer.id}"
  auto_accept               = true

  tags = "${local.tags}"
}

resource "aws_route" "database_primary_to_secondary" {
  route_table_id            = "${module.primary.database_route_table_id}"
  destination_cidr_block    = "${local.secondary_cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.peer.id}"
}

resource "aws_route" "database_secondary_to_primary" {
  provider = "aws.secondary"

  route_table_id            = "${module.secondary.database_route_table_id}"
  destination_cidr_block    = "${local.primary_cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.peer.id}"
}
