variable "db_master_password" {
  type      = string
  sensitive = true
  description = "Master password for DB (store in tfvars or SSM)"
}
