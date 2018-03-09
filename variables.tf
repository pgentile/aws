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

variable "ssh_private_key_file" {
  description = "SSH private key file"
  default     = "~/.ssh/id_rsa"
}

variable "ssh_public_key_file" {
  description = "SSH public key"
  default     = "~/.ssh/id_rsa.pub"
}

locals {
  default_tags = {
    Name        = "example"
    Provisioner = "terraform"
  }
}
