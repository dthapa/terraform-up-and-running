terraform {
  required_version = ">= 0.8, <= 0.9.11"
  backend "s3" {
    bucket = "don-terraform-up-and-running-state"
    key = "stage/mysql/s3/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform_utils"
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_db_instance" "example" {
  engine = "mysql"
  allocated_storage = 10
  instance_class = "db.t2.micro"
  name = "example_database"
  username = "admin"
  password = "${var.db_password}"
  skip_final_snapshot = true
}
