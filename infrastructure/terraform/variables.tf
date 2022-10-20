variable "region" {
  type        = string
  default     = "us-east-1"
  description = "Region to deploy Gatewise"
  validation {
    condition     = contains(["us-east-1", "us-east-2", "us-west-1", "us-west-2"], var.region)
    error_message = "Region must be in us-east-1, us-east-2, us-west-1, or us-west-2"
  }
}
variable "vpc_name" {
  type        = string
  default     = "lhtran-core-vpc"
  description = "VPC id to deploy Gatewise"
}
variable "env" {
  type        = string
  default     = "development"
  description = "Environment"
  validation {
    condition     = contains(["production", "development", "test"], var.env)
    error_message = "Environment must be production, development or test"
  }
}
variable "keypair_name" {
  type        = string
  default     = "lhtran-core-keypair"
  description = "Name of the existing keypair to connect to the instance"
}
variable "ami_name" {
  type        = string
  default     = "ami-gatewise-ubuntu-22.02-arm64"
  description = "Name of the existing Gatewise AMI"
}
variable "gatewise_instance_type" {
  type        = string
  default     = "t4g.nano"
  description = "Instance type for gatewise app"
}
variable "hostname" {
  type        = string
  default     = "gatewiseb.lhtran.com"
  description = "Domain on Route53"
}