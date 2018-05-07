resource "aws_db_subnet_group" "database" {
  name       = "lamp"
  subnet_ids = ["${data.terraform_remote_state.vpc.public_subnet_ids}"]

  tags {
    Name = "${var.name}"
    Environment = "${var.environment}"
  }
}