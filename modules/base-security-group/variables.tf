variable "name" {
  description = "Network name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks with full access allowed"
  type        = list(string)
}

variable "tags" {
  description = "Tags"
  default     = {}
}
