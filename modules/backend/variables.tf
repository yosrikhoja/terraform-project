variable "vpc_cidr" { default = "10.0.0.0/16" }
variable "public_subnet_cidr" { default = "10.0.1.0/24" }
variable "private_subnet_1_cidr" { default = "10.0.2.0/24" }
variable "private_subnet_2_cidr" { default = "10.0.3.0/24" }

variable "instance_type" { default = "t2.micro" }
variable "ami_id" { description = "AMI ID for EC2" }

variable "availability_zones" {
  type = list(string)
  default = ["us-east-1a", "us-east-1b"]
}
