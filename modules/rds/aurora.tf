variable "aurora_instance_class" {
  description = "Instance class for Aurora instances (e.g., db.r6g.large or db.t4g.medium)"
  type        = string
  default     = "db.t4g.medium"
}

variable "aurora_writer_count" {
  description = "Number of writer instances (usually 1). We keep 1 writer for simplicity."
  type        = number
  default     = 1
}

variable "aurora_reader_count" {
  description = "Number of reader instances (optional)"
  type        = number
  default     = 0
}

variable "db_master_username" {
  description = "Master username for Aurora"
  type        = string
  default     = "dbadmin"
}

variable "db_master_password" {
  description = "Master password for Aurora"
  type        = string
  sensitive   = true
  default     = null
}

variable "db_cluster_name" {
  description = "Aurora cluster identifier"
  type        = string
  default     = null
}

variable "backup_retention_period_aurora" {
  description = "Aurora backup retention days"
  type        = number
  default     = 3
}

variable "deletion_protection_aurora" {
  description = "Enable deletion protection for Aurora cluster"
  type        = bool
  default     = false
}

resource "aws_rds_cluster" "this" {
  count                        = var.use_aurora ? 1 : 0
  cluster_identifier           = coalesce(var.db_cluster_name, "${var.name}-aurora")
  engine                       = var.engine
  engine_version               = var.engine_version
  database_name                = var.db_name
  master_username              = var.db_master_username
  master_password              = var.db_master_password
  db_subnet_group_name         = aws_db_subnet_group.this.name
  vpc_security_group_ids       = [aws_security_group.this.id]
  port                         = var.db_port
  deletion_protection          = var.deletion_protection_aurora
  backup_retention_period      = var.backup_retention_period_aurora
  apply_immediately            = true
  skip_final_snapshot          = true
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.cluster_pg[0].name

  tags = merge(var.tags, { Name = "${var.name}-aurora" })
}


resource "aws_rds_cluster_instance" "writer" {
  count                = var.use_aurora ? var.aurora_writer_count : 0
  identifier           = "${var.name}-aurora-writer-${count.index}"
  cluster_identifier   = aws_rds_cluster.this[0].id
  instance_class       = var.aurora_instance_class
  engine               = var.engine
  engine_version       = var.engine_version
  db_subnet_group_name = aws_db_subnet_group.this.name
  publicly_accessible  = false
  apply_immediately    = true
  auto_minor_version_upgrade = true

  tags = merge(var.tags, { Role = "writer" })
}


resource "aws_rds_cluster_instance" "reader" {
  count                = var.use_aurora ? var.aurora_reader_count : 0
  identifier           = "${var.name}-aurora-reader-${count.index}"
  cluster_identifier   = aws_rds_cluster.this[0].id
  instance_class       = var.aurora_instance_class
  engine               = var.engine
  engine_version       = var.engine_version
  db_subnet_group_name = aws_db_subnet_group.this.name
  publicly_accessible  = false
  apply_immediately    = true
  auto_minor_version_upgrade = true

  tags = merge(var.tags, { Role = "reader" })
}
