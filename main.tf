module "rds" {
  source = "./modules/rds"

  name                   = "app-db"
  use_aurora             = false
  engine                 = "postgres"
  engine_version         = "14.11"
  parameter_group_family = "postgres14"

  # сеть
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  allowed_cidr_blocks = []   # для доступа лучше использовать SG→SG правило (см. rds_access.tf)

  # порт/имя БД/креды
  db_port   = 5432
  db_name   = "appdb"
  username  = "dbadmin"
  password  = var.db_master_password   # держи в tfvars/SSM

  # размер/класс/бэкапы
  instance_class        = "db.t4g.micro"
  allocated_storage     = 20
  max_allocated_storage = 100
  multi_az              = false

  tags = {
    Project = "Progect"
    Env     = "dev"
  }
}

module "monitoring" {
  source        = "./modules/monitoring"
  namespace     = "monitoring"
  chart_version = "65.5.0"
  # за потреби можна прокинути кастомні values:
  # values_yaml = file("${path.module}/monitoring-values.override.yaml")
}

