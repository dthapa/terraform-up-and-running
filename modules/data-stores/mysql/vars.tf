variable "db_admin" {
  description = "The admin username for the database"
  default = "admin"
}
variable "db_password" {
  description = "The password for the database"
}

variable "cluster_name" {
  description = "The name to use for all cluster resources"
}

variable "instance_type" {
  description = "The type of EC2 Instance to run"
  default = "t2.micro"
}

variable "allocated_storage" {
  description = "Allocated storage for db instance"
  default = 10
}
