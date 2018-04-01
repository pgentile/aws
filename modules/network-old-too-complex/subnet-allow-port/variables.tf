variable "first_rule_number" {
  description = "First rule number"
  type        = "string"
}

variable "egress_network_acl_id" {
  description = "Egress network ACL ID"
  type        = "string"
}

variable "egress_cidr_blocks" {
  description = "Egress CIDR blocks"
  type        = "list"
}

variable "ingress_network_acl_id" {
  description = "Ingress network ACL ID"
  type        = "string"
}

variable "ingress_cidr_blocks" {
  description = "Ingress CIDR blocks"
  type        = "list"
}

variable "port" {
  description = "Port"
  type        = "string"
}

variable "protocol" {
  description = "Protocol"
  default     = "tcp"
}
