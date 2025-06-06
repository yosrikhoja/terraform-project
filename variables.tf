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
variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string  
    default     = "ami-0f88e80871fd81e91" # Replace with a valid AMI ID
  
}
variable "s3_bucket_name" {
  description = "S3 bucket name for storing files"
  type        = string
  default     = "auto-backup-s3-bucket" # Replace with a unique bucket name
}