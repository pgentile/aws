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
  tags = {
    Name        = "example"
    Env         = "EXAMPLE"
    Provisioner = "terraform"
  }

  primary_region                      = "eu-west-3"
  primary_cidr_block                  = "10.0.0.0/16"
  primary_availability_zones          = ["eu-west-3a", "eu-west-3b"]
  primary_database_availability_zones = ["eu-west-3a", "eu-west-3b", "eu-west-3c"]

  secondary_region                      = "eu-west-1"
  secondary_cidr_block                  = "10.1.0.0/16"
  secondary_availability_zones          = ["eu-west-1a", "eu-west-1b"]
  secondary_database_availability_zones = ["eu-west-1a", "eu-west-1b"]
}
