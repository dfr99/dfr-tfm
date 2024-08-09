variable "name_prefix" {
  type        = string
  description = "value to be prefixed to all resources"
  default     = "nextcloud"
  sensitive   = false
}

variable "rds_password" {
  type        = string
  description = "password for the RDS instance"
  sensitive   = true
}
