resource "random_password" "mysql" {
  length           = 16
  special          = false
  override_special = ""
}

resource "random_password" "postgres" {
  length           = 16
  special          = false
  override_special = ""
}

resource "aws_secretsmanager_secret" "mysql" {
  name                    = "${var.project_name}/rds/mysql"
  recovery_window_in_days = 0
  tags = merge(var.tags, {
    Name = "${var.project_name}-mysql-secret"
  })
}

resource "aws_secretsmanager_secret_version" "mysql" {
  secret_id = aws_secretsmanager_secret.mysql.id
  secret_string = jsonencode({
    username = "admin"
    password = random_password.mysql.result
    host     = aws_db_instance.mysql.address
    port     = 3306
    dbname   = var.mysql_db_name
  })
}

resource "aws_secretsmanager_secret" "postgres" {
  name                    = "${var.project_name}/rds/postgres"
  recovery_window_in_days = 0
  tags = merge(var.tags, {
    Name = "${var.project_name}-postgres-secret"
  })
}

resource "aws_secretsmanager_secret_version" "postgres" {
  secret_id = aws_secretsmanager_secret.postgres.id
  secret_string = jsonencode({
    username = "dbadmin"
    password = random_password.postgres.result
    host     = aws_db_instance.postgres.address
    port     = 5432
    dbname   = var.postgres_db_name
  })
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids
  tags = merge(var.tags, {
    Name = "${var.project_name}-db-subnet-group"
  })
}

resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Allow database access from EKS nodes only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from EKS"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.eks_security_group_id]
  }

  ingress {
    description     = "PostgreSQL from EKS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.eks_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-rds-sg"
  })
}

resource "aws_db_instance" "mysql" {
  identifier        = "${var.project_name}-mysql"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = var.instance_class
  allocated_storage = 20

  db_name  = var.mysql_db_name
  username = "admin"
  password = random_password.mysql.result

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  skip_final_snapshot     = true
  deletion_protection     = false
  backup_retention_period = 0
  publicly_accessible     = false

  tags = merge(var.tags, {
    Name = "${var.project_name}-mysql"
  })
}

resource "aws_db_instance" "postgres" {
  identifier        = "${var.project_name}-postgres"
  engine            = "postgres"
  engine_version    = "16.3"
  instance_class    = var.instance_class
  allocated_storage = 20

  db_name  = var.postgres_db_name
  username = "dbadmin"
  password = random_password.postgres.result

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  skip_final_snapshot     = true
  deletion_protection     = false
  backup_retention_period = 0
  publicly_accessible     = false

  tags = merge(var.tags, {
    Name = "${var.project_name}-postgres"
  })
}
