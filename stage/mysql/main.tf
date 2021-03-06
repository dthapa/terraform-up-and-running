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


module "mysql" {
  source = "../../modules/data-stores/mysql"

  cluster_name = "mysqlstage"
  db_password = "summer2017"
}
