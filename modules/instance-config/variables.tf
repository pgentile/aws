variable "hostname" {
  description = "Instance host name"
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
