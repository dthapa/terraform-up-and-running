terraform {
  required_version = ">= 0.8, <= 0.9.11"
  backend "s3" {
    bucket = "don-terraform-up-and-running-state"
    key = "stage/services/webserver/s3/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform_utils"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  cluster_name = "webservers-stage"
  db_remote_state_bucket = "${var.db_remote_state_bucket}"
  db_remote_state_key = "${var.db_remote_state_key}"

  instance_type = "t2.micro"
  min_size = 2
  max_size = 2
}

resource "aws_security_group_rule" "allow_testing_inboud" {
  type = "ingress"
  security_group_id = "${module.webserver_cluster.elb_security_group_id}"

  from_port = 12345
  protocol = "tcp"
  to_port = 12345
  cidr_blocks = [ "0.0.0.0/0" ]
}
