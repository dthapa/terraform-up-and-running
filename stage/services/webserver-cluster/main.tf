terraform {
  required_version = ">= 0.8, <= 0.9.11"
  backend "s3" {
    bucket = "don-terraform-up-and-running-state"
    key = "stage/services/webserver/s3/terraform.tfstate"
    bucket = "don-terraform-up-and-running-state"
    region = "us-east-1"
    dynamodb_table = "terraform_utils"
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_launch_configuration" "exmaple" {
  image_id = "ami-40d28157"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.instance.id}"]
  user_data = "${data.template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "user_data" {
  template = "${file("user-data.sh")}"

  vars {
    server_port = "${var.sever_port}"
    db_address = "${data.terraform_remote_state.db.address}"
    db_port = "${data.terraform_remote_state.db.port}"
  }
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = "${aws_launch_configuration.exmaple.id}"
  max_size = 10
  min_size = 2

  availability_zones = ["${data.aws_availability_zones.all.names}"]
  load_balancers = ["${aws_elb.example.name}"]
  health_check_type = "ELB"

  tag {
    key = "Name"
    value = "terraform-asg-example"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port = "${var.sever_port}"
    protocol = "tcp"
    to_port = "${var.sever_port}"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_availability_zones" "all" {

}

data "terraform_remote_state" "db" {
  backend = "s3"

  config {
    bucket = "${var.db_remote_state_bucket}"
    key = "${var.db_remote_state_key}"
    region = "us-east-1"
  }
}

resource "aws_elb" "example" {
  name = "terraform-asg-example"
  availability_zones = [ "${data.aws_availability_zones.all.names}"]
  security_groups = [ "${aws_security_group.elb.id}"]

  listener {
    instance_port = "${var.sever_port}"
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    interval = 30
    target = "HTTP:${var.sever_port}/"
    timeout = 3
    unhealthy_threshold = 2
  }
}

resource "aws_security_group" "elb" {
  name = "terraform-example-elb"

  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}