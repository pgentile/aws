variable "name" {
  description = "Group name"
  type        = "string"
}

variable "key_name" {
  description = "SSH key name"
  type        = "string"
}

variable "associate_public_ip_address" {
  description = "Associer une IP publique à l'instance"
  default     = true
}

variable "subnet_ids" {
  description = "Subnet IDs"
  type        = "list"
}

variable "security_group_ids" {
  description = "Security group IDs"
  type        = "list"
}

variable "instance_config_s3_bucket_id" {
  description = "Instance S3 bucket ID"
  type        = "string"
}

variable "instance_config_s3_bucket_arn" {
  description = "Instance S3 bucket ARN"
  type        = "string"
}

variable "instance_config_s3_domain_name" {
  description = "Instance S3 domain name"
  type        = "string"
}

variable "tags" {
  description = "Tags"
  default     = {}
}
