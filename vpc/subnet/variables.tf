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

variable "internet_gateway_id" {
  description = "Internet gateway ID"
  type        = "string"
  default     = ""
}

locals {
  default_tags  = "${merge(var.tags, map("Name", var.name))}"
  network_names = "${formatlist("%s-%s", var.name, var.availability_zones)}"
}
