# --- RDS PostgreSQL Database ---

resource "aws_rds_cluster" "wikijs" {
  cluster_identifier      = "${var.project_name}-db-cluster"
  engine                  = "aurora-postgresql"
  engine_version          = "15.4"
  database_name           = "wikijs"
  master_username         = var.db_username
  master_password         = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.default.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  skip_final_snapshot     = true # Set to false in production
  backup_retention_period = 7
  preferred_backup_window = "07:00-09:00"
  storage_encrypted       = true
  apply_immediately       = true

  tags = {
    Name = "${var.project_name}-db-cluster"
  }
}

resource "aws_rds_cluster_instance" "wikijs_instance" {
  count                = 2 # Multi-AZ for high availability
  identifier           = "${var.project_name}-db-instance-${count.index}"
  cluster_identifier   = aws_rds_cluster.wikijs.id
  instance_class       = var.db_instance_type
  engine               = aws_rds_cluster.wikijs.engine
  engine_version       = aws_rds_cluster.wikijs.engine_version
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.default.name

  tags = {
    Name = "${var.project_name}-db-instance-${count.index}"
  }
}
