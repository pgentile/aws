variable "name" {
  description = "Instance name"
  type        = "string"
}

variable "key_name" {
  description = "SSH key name"
  type        = "string"
}

variable "associate_public_ip_address" {
  description = "Associer une IP publique à l'instance"
  default     = false
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = "string"
}

variable "security_group_ids" {
  description = "Security group IDs"
  type        = "list"
}

variable "tags" {
  description = "Tags"
  default     = {}
}

variable "iam_instance_profile_id" {
  description = "IAM instance profile ID"
  default     = ""
}

variable "ssh_allow_tcp_forwarding" {
  description = "Allow SSH TCP forwarding (must be yes for SSH basion hosts)"
  default     = "no"
}

variable "ssh_allow_agent_forwarding" {
  description = "Allow SSH agent forwarding (must be yes for SSH basion hosts)"
  default     = "no"
}
