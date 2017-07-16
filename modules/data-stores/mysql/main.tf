

resource "aws_db_instance" "example" {
  engine = "mysql"
  allocated_storage = "${var.allocated_storage}"
  instance_class = "db.${var.instance_type}"
  name = "${var.cluster_name}"
  username = "${var.db_admin}"
  password = "${var.db_password}"
  skip_final_snapshot = true
}
