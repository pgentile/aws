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

locals {
  default_tags = {
    Name        = "example"
    Provisioner = "terraform"
  }
}
