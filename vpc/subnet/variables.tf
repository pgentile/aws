variable "name" {
  description = "Network name"
  type        = "string"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = "string"
}

variable "tags" {
  description = "Tags"
  type        = "map"
  default     = {}
}

variable "cidr_blocks" {
  description = "CIDR blocks"
  type        = "list"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = "list"
}

variable "public" {
  description = "It is a public network ?"
  type        = "string"
  default     = false
}

locals {
  default_tags  = "${merge(var.tags, map("Name", var.name))}"
  subnet_names = "${formatlist("%s-%s", var.name, var.availability_zones)}"
}
