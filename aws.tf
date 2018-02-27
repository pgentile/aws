locals {
  region = "eu-west-3"
}

provider "aws" {
  region = "${local.region}"
}
