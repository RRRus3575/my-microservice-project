variable "name" {
  description = "Base name/prefix for all RDS resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where RDS will live"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for DB subnet group"
  type        = list(string)
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the DB port (ingress). Prefer security group references in production."
  type        = list(string)
  default     = []
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 5432
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}

variable "use_aurora" {
  description = "If true - create Aurora Cluster; if false - create single RDS instance"
  type        = bool
  default     = false
}

variable "engine" {
  description = "Engine type (postgres, mysql, aurora-postgresql, aurora-mysql)"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Engine version. Example: 14.11 for Postgres; 8.0.35 for MySQL; 14.7 for aurora-postgresql"
  type        = string
  default     = null
}

variable "parameter_group_family" {
  description = "Parameter group family (e.g., postgres14, mysql8.0, aurora-postgresql14, aurora-mysql8.0). If null, a heuristic will be used."
  type        = string
  default     = null
}

variable "parameter_overrides" {
  description = "Map of parameter name -> value for parameter group overrides"
  type        = map(string)
  default = {
    max_connections = "200"
    log_statement   = "none"
    work_mem        = "4MB"
  }
}

resource "aws_security_group" "this" {
  name        = "${var.name}-rds-sg"
  description = "Security group for ${var.name} database"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.name}-rds-sg" })

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "ingress_cidr" {
  count             = length(var.allowed_cidr_blocks) > 0 ? 1 : 0
  type              = "ingress"
  from_port         = var.db_port
  to_port           = var.db_port
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = aws_security_group.this.id
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-db-subnet"
  subnet_ids = var.private_subnet_ids
  tags       = merge(var.tags, { Name = "${var.name}-db-subnet" })
}

locals {
  derived_parameter_group_family = (
    var.parameter_group_family != null ? var.parameter_group_family :
    (
      var.use_aurora
        ? (contains(lower(var.engine), "postgres") ? "aurora-postgresql14" : "aurora-mysql8.0")
        : (var.engine == "postgres" ? "postgres14" : "mysql8.0")
    )
  )
}

resource "aws_db_parameter_group" "instance_pg" {
  count  = var.use_aurora ? 0 : 1
  name   = "${var.name}-db-pg"
  family = local.derived_parameter_group_family
  tags   = merge(var.tags, { Name = "${var.name}-db-pg" })

  dynamic "parameter" {
    for_each = var.parameter_overrides
    content {
      name  = parameter.key
      value = parameter.value
    }
  }
}

resource "aws_rds_cluster_parameter_group" "cluster_pg" {
  count  = var.use_aurora ? 1 : 0
  name   = "${var.name}-cluster-pg"
  family = local.derived_parameter_group_family
  tags   = merge(var.tags, { Name = "${var.name}-cluster-pg" })

  dynamic "parameter" {
    for_each = var.parameter_overrides
    content {
      name  = parameter.key
      value = parameter.value
    }
  }
}
