output "security_group_id" {
  value       = aws_security_group.this.id
  description = "Security group ID for the DB"
}

output "db_subnet_group_name" {
  value       = aws_db_subnet_group.this.name
  description = "DB subnet group name"
}

output "parameter_group_name" {
  value       = var.use_aurora ? aws_rds_cluster_parameter_group.cluster_pg[0].name : aws_db_parameter_group.instance_pg[0].name
  description = "Parameter group name"
}

output "endpoint" {
  value       = var.use_aurora ? aws_rds_cluster.this[0].endpoint : aws_db_instance.this[0].address
  description = "Writer endpoint (Aurora) or instance endpoint"
}

output "reader_endpoint" {
  value       = var.use_aurora ? aws_rds_cluster.this[0].reader_endpoint : null
  description = "Aurora reader endpoint (null for single instance)"
}
