terraform {
  required_version = ">= 0.8, <= 0.9.11"
  backend "s3" {
    bucket = "don-terraform-up-and-running-state"
    key = "prod/services/webserver/s3/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform_utils"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  cluster_name = "webservers-prod"
  db_remote_state_bucket = "don-terraform-up-and-running-state"
  db_remote_state_key = "prod/mysql/terraform.tfstate"

  instance_type = "m4.large"
  min_size = 2
  max_size = 10
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  autoscaling_group_name = "${module.webserver_cluster.asg_name}"
  scheduled_action_name = "scale_out_during_business_hours"
  min_size = 2
  max_size = 10
  desired_capacity = 10
  recurrence = "0 9 * * *"
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  autoscaling_group_name = "${module.webserver_cluster.asg_name}"
  scheduled_action_name = "scale_in_at_night"
  min_size = 2
  max_size = 10
  desired_capacity = 2
  recurrence = "0 17 * * *"
}
