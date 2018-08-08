variable "environment" {
  description = "Environment name to deploy to (qa, prod, etc.)"
}

variable "instance_type" {
  description = "The type of instance to launch"
  default     = "t2.micro"
}

variable "name" {
  description = "The name of the application"
}

variable "profile" {
  description = "The profile with credentials of the AWS account to deploy to"
}

variable "region" {
  description = "The region to deploy to"
}

variable "tfstate_bucket" {}
