#Database Layer
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "aws_secretsmanager_secret" "employee_registry" {
  name        = "employee-registry-credentials"
  description = "Database credentials for employee registry PostgreSQL"
}

resource "aws_secretsmanager_secret_version" "employee_registry" {
  secret_id = aws_secretsmanager_secret.employee_registry.id
  secret_string = jsonencode({
    username = "user_registry"
    password = random_password.password.result
    db_name  = "postgres"
  })

  lifecycle {
    ignore_changes = [
      secret_string
    ]
  }
}

resource "aws_db_subnet_group" "postgresql" {
  name       = "employee-registry-subnet-group"
  subnet_ids = var.private_subnets_ids

  tags = {
    Name = "Employee Registry DB Subnet Group"
  }
}


resource "aws_db_instance" "postgresql" {
  identifier              = "employee-registry-postgresql"
  engine                  = "postgres"
  instance_class          = var.db_instance_class
  allocated_storage       = var.postgres_allocated_storage
  db_name                 = jsondecode(aws_secretsmanager_secret_version.employee_registry.secret_string).db_name
  username                = jsondecode(aws_secretsmanager_secret_version.employee_registry.secret_string).username
  password                = jsondecode(aws_secretsmanager_secret_version.employee_registry.secret_string).password
  backup_retention_period = var.backup_retention_period
  backup_window           = var.postgres_backup_window
  storage_encrypted       = true
  deletion_protection     = true
  vpc_security_group_ids  = [aws_security_group.rds.id]
  db_subnet_group_name    = aws_db_subnet_group.postgresql.name
}


