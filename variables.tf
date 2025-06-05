# variables.tf
variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "hosted_zone_id" {
  description = "Hosted zone ID for Route 53"
  type        = string
}