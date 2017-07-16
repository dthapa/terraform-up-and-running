resource "aws_launch_configuration" "exmaple" {
  image_id = "ami-40d28157"
  instance_type = "${var.instance_type}"
  security_groups = ["${aws_security_group.instance.id}"]
  user_data = "${data.template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user-data.sh")}"

  vars {
    server_port = "${var.sever_port}"
    db_address = "${var.db_remote_state_bucket}"
    db_port = "${var.db_remote_state_key}"
//    db_address = "${data.terraform_remote_state.db.address}"
//    db_port = "${data.terraform_remote_state.db.port}"
  }
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = "${aws_launch_configuration.exmaple.id}"
  max_size = "${var.max_size}"
  min_size = "${var.min_size}"

  availability_zones = ["${data.aws_availability_zones.all.names}"]
  load_balancers = ["${aws_elb.example.name}"]
  health_check_type = "ELB"

  tag {
    key = "Name"
    value = "${var.cluster_name}-asg"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "instance" {
  name = "${var.cluster_name}-instance"

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
  name = "${var.cluster_name}-asg"
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
  name = "${var.cluster_name}-elb"
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type = "ingress"
  security_group_id = "${aws_security_group.elb.id}"

  from_port = 80
  protocol = "tcp"
  to_port = 80
  cidr_blocks = [ "0.0.0.0/0" ]
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type = "egress"
  security_group_id = "${aws_security_group.elb.id}"

  from_port = 0
  protocol = "-1"
  to_port = 0
  cidr_blocks = [ "0.0.0.0/0" ]
}
