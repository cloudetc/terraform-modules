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

variable "profile" {}

variable "region" {}

variable "name" {}

variable "environment" {}