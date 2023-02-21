# Security group
module "mysql_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"

  name        = "${var.env}-mysql-sg"
  description = "${var.env} Mysql security group"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "mysql-tcp"
      source_security_group_id = data.terraform_remote_state.workspaces.outputs.security_group_id
      description              = "mysql access from workspaces security group"
    },
  ]

    egress_with_source_security_group_id = [
    {
      rule                     = "mysql-tcp"
      source_security_group_id = data.terraform_remote_state.workspaces.outputs.security_group_id
      description              = "mysql access to security group"
    }
    ]

    ingress_with_self = [
        {
        rule                     = "all-all"
        description              = "Allow all inbound traffic within the security group"
        }
    ]
    egress_with_self = [
        {
        rule                     = "all-all"
        description              = "Allow all outbound traffic within the security group"
        }

    ]
      ingress_with_cidr_blocks = [
    {
      rule        = "mysql-tcp"
      cidr_blocks = "10.0.0.0/16"
    }
    ]
}

module "db" {
  source = "terraform-aws-modules/rds/aws"
  identifier = "cms5poc-${var.env}"
  version = "~> 5.0"
  engine               = "mysql"
  engine_version       = "8.0"
  family               = "mysql8.0" # DB parameter group
  major_engine_version = "8.0"      # DB option group
  instance_class          = "db.t3.micro"
  create_db_subnet_group    = true
  create_db_parameter_group = true
  create_db_option_group    = true
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = true

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  db_name  = var.rds_dbname
  username = var.rds_username
  password = var.rds_password
  port     = 3306

  multi_az               = false
  subnet_ids             = data.terraform_remote_state.vpc.outputs.private_subnets
  vpc_security_group_ids = [module.mysql_security_group.security_group_id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["general"]
  create_cloudwatch_log_group     = true
  blue_green_update = {
    enabled = true
  }

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

#   performance_insights_enabled          = false
#   performance_insights_retention_period = 7
#   create_monitoring_role                = false
#   monitoring_interval                   = 60
#   monitoring_role_name                  = "ji-gitlab-server-monitoring-role"
#   monitoring_role_description           = "Description for monitoring role"

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  db_instance_tags = {
      Name = "${var.env}-cms5poc"
  }

  db_option_group_tags = {
      Name = "${var.env}-rds-db-option-group"
  }

  db_parameter_group_tags = {
      Name = "${var.env}-rds-parameter-group"
  }

  db_subnet_group_tags = {
      Name = "${var.env}-rds-subnet-group"
  }
}