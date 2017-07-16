variable "db_remote_state_bucket" {
  description = "The name of the S3 bucket used for the database's remote state storage"
  default = "don-terraform-up-and-running-state"
}

variable "db_remote_state_key" {
  description = "The name of the key in the S3 bucket used for the database's remote state storage"
  default = "stage/mysql/s3/terraform.tfstate"
}
