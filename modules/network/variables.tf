variable "name" {
  description = "Network name"
  type        = "string"
}

variable "cidr_block" {
  description = "CIDR block of the VPC"
  type        = "string"
}

variable "public_subnet_cidr_blocks" {
  description = "CIDR block of the public subnet"
  default     = []
}

variable "private_subnet_cidr_blocks" {
  description = "CIDR block of the private subnet"
  default     = []
}

variable "availability_zones" {
  description = "AWS availability zones"
  type        = "list"
}

variable "tags" {
  description = "Tags"
  default     = {}
}
