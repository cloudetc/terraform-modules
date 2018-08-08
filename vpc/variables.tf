variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "database_subnets" {
  type = "list"
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "webserver_subnets" {
  type = "list"
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "profile" {
  description = "The profile with credentials of the AWS account to deploy to"
}

variable "region" {
  description = "The region to deploy to"
}

variable "name" {
  description = "Name of the application"
}

variable "environment" {
  description = "Environment name to deploy to (qa, prod, etc.)"
}