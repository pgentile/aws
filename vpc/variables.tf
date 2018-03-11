variable "name" {
  description = "VPC name"
  type        = "string"
}

variable "tags" {
  description = "Tags"
  type        = "map"
  default     = {}
}

variable "cidr_block" {
  description = "CIDR block of the VPC"
  type        = "string"
}

variable "public_availability_zones" {
  description = "Public availability zones"
  type        = "list"
  default     = []
}

variable "public_cidr_blocks" {
  description = "Public CIDR blocks"
  type        = "list"
  default     = []
}

variable "private_availability_zones" {
  description = "Private availability zones"
  type        = "list"
  default     = []
}

variable "private_cidr_blocks" {
  description = "Private CIDR blocks"
  type        = "list"
  default     = []
}

variable "private_gateway_network_interface_id" {
  description = "Private network gateway interface ID"
  type        = "string"
  default     = ""
}

locals {
  default_tags = "${merge(var.tags, map("Name", var.name))}"
}
