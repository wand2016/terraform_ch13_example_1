variable "mysql_version" {
  type = string
  default = "5.7"
}

resource "aws_db_parameter_group" "example" {
  name = "example"
  family = "mysql${var.mysql_version}"

  parameter {
    name = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name = "character_set_server"
    value = "utf8mb4"
  }
}

resource "aws_db_option_group" "example" {
  name = "example"
  engine_name = "mysql"
  major_engine_version = var.mysql_version

  option {
    option_name = "MARIADB_AUDIT_PLUGIN"
  }
}
