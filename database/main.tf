provider "aws" {
  version = "~> 1.0"

  profile = "${var.profile}"
  region = "${var.region}"
}

terraform {
  backend "s3" {}
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    region = "${var.region}"
    bucket = "${var.tfstate_bucket}"
    key = "vpc/terraform.tfstate"
  }
}

resource "aws_db_subnet_group" "database" {
  name       = "lamp"
  subnet_ids = ["${data.terraform_remote_state.vpc.private_subnet_ids}"]

  tags {
    Name = "${var.name}"
    Environment = "${var.environment}"
  }
}

resource "aws_db_instance" "database" {
  allocated_storage    = 5
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.6.34"
  instance_class       = "db.t2.micro"
  name                 = "lamp"
  username             = "lamp"
  password             = "lamp1234"
  db_subnet_group_name = "${aws_db_subnet_group.database.name}"
  parameter_group_name = "default.mysql5.6"
  availability_zone = "us-west-2a"
  vpc_security_group_ids = ["${aws_security_group.database.id}"]
  skip_final_snapshot = true

  # multi_az = true

  tags {
    Name = "${var.name}"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "database" {
  name = "webserver -: database"
  description = "Allow connections from webservers"
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["${data.terraform_remote_state.vpc.public_subnets_cidr_blocks}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.name}: Database"
    Environment = "${var.environment}"
  }
}