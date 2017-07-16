variable "sever_port" {
  description = "The port the server will use for HTTP requests"
  default = 8080
}

variable "db_remote_state_bucket" {
  description = "The name of the S3 bucket used for the database's remote state storage"
}

variable "db_remote_state_key" {
  description = "The name of the key in the S3 bucket used for the database's remote state storage"
}

variable "cluster_name" {
  description = "The name to use for all cluster resources"
}

variable "instance_type" {
  description = "The type of EC2 Instance to run"
  default = "t2.micro"
}

variable "min_size" {
  description = "The mininum number of EC2 instances in the ASG"
}

variable "max_size" {
  description = "The maximum number of EC2 instances in the ASG"
}