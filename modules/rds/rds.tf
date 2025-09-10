variable "instance_class" {
  description = "Instance class for single RDS instance (e.g., db.t4g.micro)"
  type        = string
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  description = "Allocated storage for single RDS instance (in GB)"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Max storage autoscaling (GB)"
  type        = number
  default     = 100
}

variable "multi_az" {
  description = "Enable Multi-AZ for the instance"
  type        = bool
  default     = false
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = null
}

variable "username" {
  description = "Master username (for non-Aurora)"
  type        = string
  default     = "dbadmin"
}

variable "password" {
  description = "Master password (for non-Aurora)"
  type        = string
  sensitive   = true
  default     = null
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Backup retention days"
  type        = number
  default     = 3
}

variable "publicly_accessible" {
  description = "Whether the instance is publicly accessible"
  type        = bool
  default     = false
}

resource "aws_db_instance" "this" {
  count                        = var.use_aurora ? 0 : 1
  identifier                   = "${var.name}-rds"
  engine                       = var.engine
  engine_version               = var.engine_version
  instance_class               = var.instance_class
  db_subnet_group_name         = aws_db_subnet_group.this.name
  vpc_security_group_ids       = [aws_security_group.this.id]
  allocated_storage            = var.allocated_storage
  max_allocated_storage        = var.max_allocated_storage
  multi_az                     = var.multi_az
  port                         = var.db_port
  db_name                      = var.db_name
  username                     = var.username
  password                     = var.password
  parameter_group_name         = aws_db_parameter_group.instance_pg[0].name
  deletion_protection          = var.deletion_protection
  backup_retention_period      = var.backup_retention_period
  publicly_accessible          = var.publicly_accessible
  apply_immediately            = true
  auto_minor_version_upgrade   = true
  skip_final_snapshot          = true

  tags = merge(var.tags, { Name = "${var.name}-rds" })
}
