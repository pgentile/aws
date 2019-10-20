module "network" {
  source = "./modules/simple-network"

  name = var.env
  tags = local.env_tags

  cidr_block         = var.cidr_block
  availability_zones = var.availability_zones

  subnet_cidr_blocks = [
    cidrsubnet(var.cidr_block, 1, 0),
    cidrsubnet(var.cidr_block, 1, 1),
  ]

  allowed_cidr_blocks = ["${var.my_ip}/32"]
}

module "base_security_group" {
  source = "./modules/base-security-group"

  name = "${var.env}-base"
  tags = local.env_tags

  vpc_id              = module.network.vpc_id
  allowed_cidr_blocks = ["${var.my_ip}/32"]
}

