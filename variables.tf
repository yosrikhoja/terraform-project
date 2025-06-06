variable "db_username" {
  description = "Database administrator username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}