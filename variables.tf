variable "region" {
  description = "AWS region"

  # Paris
  default = "eu-west-3"
}

variable "availability_zones" {
  description = "AWS availability zones"

  default = [
    "eu-west-3a",
    "eu-west-3b",
    "eu-west-3c",
  ]
}

variable "cidr_block" {
  description = "CIDR block of the VPC"
  default     = "10.0.0.0/16"
}

variable "my_ip" {
  description = "My IP"
  type        = "string"
}

variable "enable_load_balancer" {
  description = "Enable load balancer ?"
  default     = false
}

variable "env" {
  description = "The env (ex: dev, test, prod)"
  default     = "test"
}

variable "platform" {
  description = "The platform (ex: dev-01, test-01, prod-01)"
  default     = "test-01"
}

locals {
  env_tags = {
    Env         = "${var.env}"
    Provisioner = "terraform"
  }

  platform_tags = "${merge(local.env_tags, map("Platform", var.platform))}"
}
