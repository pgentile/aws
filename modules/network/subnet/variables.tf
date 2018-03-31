variable "name" {
  description = "Network name"
  type        = "string"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = "string"
}

variable "availability_zones" {
  description = "AWS availability zones"
  type        = "list"
}

variable "cidr_blocks" {
  description = "CIDR blocks of each subnet"
  type        = "list"
}

variable "tags" {
  description = "Tags"
  default     = {}
}

variable "allow_internal_subnet_traffic" {
  description = "Allow all traffic in the subnet"
  default     = false
}

variable "ephemeral_ports" {
  description = "Ephemeral ports"

  // Linux ephemeral ports
  // See https://www.ncftp.com/ncftpd/doc/misc/ephemeral_ports.html#Linux
  default = {
    start = 32768
    end   = 61000
  }
}

variable "internet_gateway_id" {
  description = "Internet gateway ID"
  default     = ""
}
