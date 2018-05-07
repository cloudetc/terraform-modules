data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    region = "${var.region}"
    bucket = "${var.tfstate_bucket}"
    key = "vpc/terraform.tfstate"
  }
}

terraform {
  backend "s3" {}
}

provider "aws" {
  version = "~> 1.0"

  # default location is $HOME/.aws/credentials
  profile = "${var.profile}"
  region = "${var.region}"
}