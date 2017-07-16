terraform {
  required_version = ">= 0.8, <= 0.9.11"
  backend "s3" {
    bucket = "don-terraform-up-and-running-state"
    key = "prod/mysql/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform_utils"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "mysql" {
  source = "../../modules/data-stores/mysql"

  cluster_name = "mysqlprod"
  instance_type = "m4.large"
  db_password = "winter2017"
  allocated_storage = 20
}
