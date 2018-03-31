variable "name" {
  description = "Group name"
  type        = "string"
}

variable "key_name" {
  description = "SSH key name"
  type        = "string"
}

variable "subnet_ids" {
  description = "Subnet IDs"
  type        = "list"
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
