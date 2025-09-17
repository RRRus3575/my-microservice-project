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
  description = "Parameter group family (e.g., postgres14, mysql8.0, aurora-postgresql14, aurora-mysql8.0)"
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
