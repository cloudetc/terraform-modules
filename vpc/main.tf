provider "aws" {
  version = "~> 1.0"

  # default location is $HOME/.aws/credentials
  profile = "${var.profile}"
  region = "${var.region}"
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.37.0"

  name = "${var.name}"
  cidr = "${var.vpc_cidr_block}"

  azs           = ["${var.region}a", "${var.region}b"]
  private_subnets = ["${var.database_subnets}"]
  public_subnets  = ["${var.webserver_subnets}"]

  # tags to add to all resources
  tags = {
    Name        = "${var.name}"
    Terraform   = "true"
    Environment = "${var.environment}"
  }
}