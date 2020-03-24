# ----------------------------------------
# rds
# ----------------------------------------

variable "mysql_major_version" {
  type = string
  default = "5.7"
}
variable "mysql_minor_version" {
  type = string
  default = "5.7.25"
}
variable "mysql_port" {
  type = number
  default = 3306
}
variable "redis_port" {
  type = number
  default = 6379
}

resource "aws_db_parameter_group" "example" {
  name = "example"
  family = "mysql${var.mysql_major_version}"

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
  major_engine_version = var.mysql_major_version

  option {
    option_name = "MARIADB_AUDIT_PLUGIN"
  }
}

resource "aws_db_subnet_group" "example" {
  name = "example"
  subnet_ids = [aws_subnet.private_0.id, aws_subnet.private_1.id]
}

# resource "aws_db_instance" "example" {
#   identifier = "example"
#   engine = "mysql"
#   engine_version = var.mysql_minor_version
#   instance_class = "db.t3.small"
#   allocated_storage = 20
#   max_allocated_storage = 100
#   storage_type = "gp2"
#   storage_encrypted = true
#   kms_key_id = aws_kms_key.example.arn
#   username = "admin"
#   password = "uninitialized"
#   multi_az = true
#   publicly_accessible = false
#   backup_window = "09:10-09:40"
#   backup_retention_period = 30
#   maintenance_window = "mon:10:10-mon:10:40"
#   auto_minor_version_upgrade = false
#   deletion_protection = false
#   skip_final_snapshot = true
#   port = var.mysql_port
#   apply_immediately = false
#   vpc_security_group_ids = [module.mysql_sg.security_group_id]
#   parameter_group_name = aws_db_parameter_group.example.name
#   option_group_name = aws_db_option_group.example.name
#   db_subnet_group_name = aws_db_subnet_group.example.name

#   lifecycle {
#     ignore_changes = [password]
#   }
# }

module "mysql_sg" {
  source = "./security_group"
  name = "mysql-sg"
  vpc_id = aws_vpc.example.id
  port = var.mysql_port
  cidr_blocks = [aws_vpc.example.cidr_block]
}

# ----------------------------------------
# elasticache
# ----------------------------------------

resource "aws_elasticache_parameter_group" "example" {
  name = "example"
  family = "redis5.0"

  parameter {
    name = "cluster-enabled"
    value = "no"
  }
}

resource "aws_elasticache_subnet_group" "example" {
  name = "example"
  subnet_ids = [aws_subnet.private_0.id, aws_subnet.private_1.id]
}

resource "aws_elasticache_replication_group" "example" {
  replication_group_id = "example"
  replication_group_description = "Cluter Disabled"
  engine = "redis"
  engine_version = "5.0.4"
  number_cache_clusters = 3
  node_type = "cache.m3.medium"
  snapshot_window = "09:10-10:10"
  snapshot_retention_limit = 7
  maintenance_window = "mon:10:40-mon:11:40"
  automatic_failover_enabled = true
  port = var.redis_port
  apply_immediately = false
  security_group_ids = [module.redis_sg.security_group_id]
  parameter_group_name = aws_elasticache_parameter_group.example.name
  subnet_group_name = aws_elasticache_subnet_group.example.name
}

module "redis_sg" {
  source = "./security_group"
  name = "redis-sg"
  vpc_id = aws_vpc.example.id
  port = var.redis_port
  cidr_blocks = [aws_vpc.example.cidr_block]
}


# ----------------------------------------
# N/W
# ----------------------------------------

resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "example"
  }
}

resource "aws_subnet" "public_0" {
  vpc_id = aws_vpc.example.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "example-1a"
  }
}

resource "aws_subnet" "public_1" {
  vpc_id = aws_vpc.example.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "example-1c"
  }
}

resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id

  tags = {
    Name = "example"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.example.id

  tags = {
    Name = "example"
  }
}

resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
  gateway_id = aws_internet_gateway.example.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public_0" {
  subnet_id = aws_subnet.public_0.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_1" {
  subnet_id = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "private_0" {
  vpc_id = aws_vpc.example.id
  cidr_block = "10.0.65.0/24"
  availability_zone = "ap-northeast-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "example_private_1a"
  }
}

resource "aws_subnet" "private_1" {
  vpc_id = aws_vpc.example.id
  cidr_block = "10.0.66.0/24"
  availability_zone = "ap-northeast-1c"
  map_public_ip_on_launch = false

  tags = {
    Name = "example_private_1c"
  }
}

resource "aws_route_table" "private_0" {
  vpc_id = aws_vpc.example.id

  tags = {
    Name = "example_private_0"
  }
}

resource "aws_route_table" "private_1" {
  vpc_id = aws_vpc.example.id

  tags = {
    Name = "example_private_1"
  }
}

resource "aws_route_table_association" "private_0" {
  subnet_id = aws_subnet.private_0.id
  route_table_id = aws_route_table.private_0.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_1.id
}

resource "aws_eip" "nat_gateway_0" {
  vpc = true
  depends_on = [aws_internet_gateway.example]
}

resource "aws_eip" "nat_gateway_1" {
  vpc = true
  depends_on = [aws_internet_gateway.example]
}

resource "aws_nat_gateway" "nat_gateway_0" {
  allocation_id = aws_eip.nat_gateway_0.id
  subnet_id = aws_subnet.public_0.id
  depends_on = [aws_internet_gateway.example]
}

resource "aws_nat_gateway" "nat_gateway_1" {
  allocation_id = aws_eip.nat_gateway_1.id
  subnet_id = aws_subnet.public_1.id
  depends_on = [aws_internet_gateway.example]
}

resource "aws_route" "private_0" {
  route_table_id = aws_route_table.private_0.id
  nat_gateway_id = aws_nat_gateway.nat_gateway_0.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "private_1" {
  route_table_id = aws_route_table.private_1.id
  nat_gateway_id = aws_nat_gateway.nat_gateway_1.id
  destination_cidr_block = "0.0.0.0/0"
}

# ----------------------------------------
# kms
# ----------------------------------------

resource "aws_kms_key" "example" {
  description = "Example Customer Master Key"
  enable_key_rotation = true
  is_enabled = false
  deletion_window_in_days = 30
}

resource "aws_kms_alias" "example" {
  name = "alias/example"
  target_key_id = aws_kms_key.example.key_id
}
