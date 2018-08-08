data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    region = "${var.region}"
    bucket = "${var.tfstate_bucket}"
    key = "vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "database" {
  backend = "s3"

  config {
    region = "${var.region}"
    bucket = "${var.tfstate_bucket}"
    key = "database/terraform.tfstate"
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

data "template_file" "index_php" {
  template = "${file("${path.module}/index.php")}"

  vars {
    db_server_address = "${data.terraform_remote_state.database.server_address}"
    environment = "${var.environment}"
  }
}


data "template_cloudinit_config" "readmodel" {
  gzip          = true
  base64_encode = false

  part {
    content_type = "text/part-handler"
    content = "${file("${path.module}/../part-handler-text.py")}"
  }

  part {
    content_type = "text/plain-base64"
    filename = "/var/www/index.php"
    content = "${base64encode("${data.template_file.index_php.rendered}")}"
  }
}

resource "aws_autoscaling_group" "webserver" {
  name = "${aws_launch_configuration.webserver.name}"
  launch_configuration = "${aws_launch_configuration.webserver.name}"

  max_size = "${4 * length(data.terraform_remote_state.vpc.public_subnet_ids)}"
  min_size = 2

  vpc_zone_identifier = ["${data.terraform_remote_state.vpc.public_subnet_ids}"]
  load_balancers = ["${aws_elb.webserver.name}"]

  tag {
    key = "Name"
    value = "${var.name}"
    propagate_at_launch = true
  }

  tag {
    key = "Environment"
    value = "${var.environment}"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "webserver" {
  name_prefix = "webserver-"
  image_id = "${data.aws_ami.webserver.id}"
  instance_type = "${var.instance_type}"
  user_data = "${data.template_cloudinit_config.readmodel.rendered}"
  security_groups = [
    "${aws_security_group.webserver.id}"
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "webserver" {
  name = "webserver-elb"
  internal = false
  subnets = ["${data.terraform_remote_state.vpc.public_subnet_ids}"]
  security_groups = ["${aws_security_group.elb.id}"]

  listener {
    instance_port = 80
    instance_protocol = "tcp"
    lb_port = 80
    lb_protocol = "tcp"
  }

  tags {
    Name = "${var.environment}: ${var.name}"
  }
}

data "aws_ami" "webserver" {
  most_recent = true
  owners = ["${data.aws_caller_identity.current.account_id}"]

  filter {
    name = "name"
    values = ["webserver-*"]
  }

  filter {
    name = "state"
    values = ["available"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "is-public"
    values = ["false"]
  }
}

data "aws_caller_identity" "current" {
  # no arguments
}

resource "aws_security_group" "webserver" {
  name = "elb -: webserver"
  description = "Allow connections from ELB"
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"

  ingress {
    from_port = 80
    to_port = 80
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
    Name = "${var.name}: webserver"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "elb" {
  name = "Internet -: ELB"
  description = "Allow connections from Internet"
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.name}: ELB"
    Environment = "${var.environment}"
  }
}
