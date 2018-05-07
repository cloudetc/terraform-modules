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