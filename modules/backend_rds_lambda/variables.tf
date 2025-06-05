variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "rds_username" {
  default = "admin"
}

variable "rds_password" {
  default = "password"
  sensitive = true
}

variable "rds_instance_class" {
  default = "db.t3.micro"
}

variable "s3_bucket_name" {
  description = "Bucket to store files exported by Lambda"
}
