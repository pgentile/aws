variable "name" {
  description = "Network name"
  type        = "string"
}

variable "cidr_block" {
  description = "CIDR block of the VPC"
  type        = "string"
}

variable "availability_zones" {
  description = "AWS availability zones"
  type        = list(string)
}

variable "subnet_cidr_blocks" {
  description = "CIDR block of the subnets"
  type = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks with full access allowed"
  type        = list(string)
}

variable "ephemeral_ports" {
  description = "Ephemeral ports"

  // Linux ephemeral ports
  // See https://www.ncftp.com/ncftpd/doc/misc/ephemeral_ports.html#Linux
  default = {
    start = 1024
    end   = 65535
  }
}

variable "tags" {
  description = "Tags"
  default     = {}
}
