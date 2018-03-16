variable "name" {
  description = "Instance name"
  type        = "string"
}

variable "key_name" {
  description = "SSH key name"
  type        = "string"
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = "string"
}

variable "vpc_security_group_ids" {
  description = "Security group IDs"
  type        = "list"
}

variable "tags" {
  description = "Tags"
  default     = {}
}
