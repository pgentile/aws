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

variable "availability_zones" {
  description = "Availability zones used by the VPC"
  type        = "list"
  default     = []
}

variable "public_cidr_blocks" {
  description = "Public CIDR blocks"
  type        = "list"
  default     = []
}

variable "private_cidr_blocks" {
  description = "Private CIDR blocks"
  type        = "list"
  default     = []
}

variable "database_cidr_blocks" {
  description = "Database CIDR blocks"
  type        = "list"
  default     = []
}

locals {
  default_tags = "${merge(var.tags, map("Name", var.name))}"
}
