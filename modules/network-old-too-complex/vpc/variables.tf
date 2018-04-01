variable "name" {
  description = "VPC name"
  type        = "string"
}

variable "cidr_block" {
  description = "CIDR block of the VPC"
  type        = "string"
}

variable "tags" {
  description = "Tags"
  default     = {}
}
