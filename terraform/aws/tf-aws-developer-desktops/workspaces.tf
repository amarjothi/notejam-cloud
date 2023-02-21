## Workspace components

resource "aws_workspaces_directory" "workspaces-directory" {
  directory_id = aws_directory_service_directory.aws-managed-ad.id
    subnet_ids = [
      data.aws_subnet.private_3.id,
      data.aws_subnet.private_2.id
      ]
  
  self_service_permissions {
    change_compute_type  = false
    increase_volume_size = false
    rebuild_workspace    = false
    restart_workspace    = true
    switch_running_mode  = false
  }  
  
  workspace_access_properties {
    device_type_android = "ALLOW"
    device_type_chromeos = "ALLOW"
    device_type_ios = "ALLOW"
    device_type_linux = "ALLOW"
    device_type_osx = "ALLOW"
    device_type_web = "ALLOW"
    device_type_windows = "ALLOW"
    device_type_zeroclient = "DENY"
  }  
  
  workspace_creation_properties {
    custom_security_group_id = aws_security_group.workspaces.id
    default_ou = "OU=cms5poc,DC=cms5poc,DC=local"
    enable_internet_access = true
    enable_maintenance_mode = false
    user_enabled_as_local_administrator = true
  }

  ip_group_ids = [
    aws_workspaces_ip_group.ntt_data.id
  ]

  depends_on = [aws_iam_role.workspaces-default]
}

resource "aws_kms_key" "workspaces-kms" {
  description = "${var.project_name} workspaces KMS ${var.env}"
  deletion_window_in_days = 7
  enable_key_rotation = true
}

##Administrator workspaces for to Admin AD
resource "aws_workspaces_workspace" "admin_workspaces" {
  directory_id = aws_workspaces_directory.workspaces-directory.id
  bundle_id = var.workspace_bundle_ids["windows10"]  # Windows 10 Pro
  user_name = "Admin"  # Admin is the Administrator of the AWS Directory Service
  root_volume_encryption_enabled = true
  user_volume_encryption_enabled = true
  volume_encryption_key = aws_kms_key.workspaces-kms.arn  
  
  workspace_properties {
    compute_type_name = "STANDARD"
    user_volume_size_gib = 50
    root_volume_size_gib = 80
    running_mode = "AUTO_STOP"
    running_mode_auto_stop_timeout_in_minutes = 60
  }  
  
  tags = {
    Name = "${var.project_name}-admin-workspace-${var.env}"
    Environment = var.env
  }  
  
  depends_on = [
    aws_iam_role.workspaces-default,
    aws_workspaces_directory.workspaces-directory
  ]
}

resource "aws_workspaces_workspace" "developer_workspaces" {
  for_each = var.developers
  directory_id = aws_workspaces_directory.workspaces-directory.id
  bundle_id = var.workspace_bundle_ids["dev_desktop_medium"]
  user_name = each.value  # Admin is the Administrator of the AWS Directory Service
  root_volume_encryption_enabled = true
  user_volume_encryption_enabled = true
  volume_encryption_key = aws_kms_key.workspaces-kms.arn  
  
  workspace_properties {
    compute_type_name = "STANDARD"
    user_volume_size_gib = 50
    root_volume_size_gib = 80
    running_mode = "AUTO_STOP"
    running_mode_auto_stop_timeout_in_minutes = 60
  }  
  
  tags = {
    Name = "${var.project_name} developer workspaces ${var.env}"
    Environment = var.env
  }  
  
  depends_on = [
    aws_iam_role.workspaces-default,
    aws_workspaces_directory.workspaces-directory
  ]
}


resource "aws_workspaces_ip_group" "ntt_data" {
  name        = "NTTDATAUK"
  description = "NTT DATA UK"
  tags = {
    Nme = "NTTDATAUK"
    Environment = var.env
    ProjectName = var.project_name
  }
  
  rules {
    source      = "82.34.158.62/32"
    description = "JamesIrvine"
  }
    rules {
    source      = "86.30.200.100/32"
    description = "ErwinWendland"
  }
    rules {
    source      = "51.183.18.228/32"
    description = "Naveen"
  }
    rules {
    source      = "91.125.196.61/32"
    description = "Rajinder"
  }
    rules {
    source      = "86.137.23.203/32"
    description = "AmarMani"
  }
}

## IAM resources for Workspaces

data "aws_iam_policy_document" "workspaces" {
  statement {
    actions = ["sts:AssumeRole"]    
    
    principals {
      type = "Service"
      identifiers = ["workspaces.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "workspaces-default" {
  name = "workspaces_DefaultRole"
  assume_role_policy = data.aws_iam_policy_document.workspaces.json
}

resource "aws_iam_role_policy_attachment" "workspaces-default-service-access" {
  role = aws_iam_role.workspaces-default.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonWorkSpacesServiceAccess"
}

resource "aws_iam_role_policy_attachment" "workspaces-default-self-service-access" {
  role = aws_iam_role.workspaces-default.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonWorkSpacesSelfServiceAccess"
}

## Security group settings

resource "aws_security_group" "workspaces" {
  #checkov:skip=CKV2_AWS_5: Prevent false positive
  name        = "${var.env}-${var.project_name}-workspaces"
  description = "${var.env} Workspaces members security group"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  tags = {
    Name = "${var.env} Workspace members"
    Enviroment = var.env
  }
}

resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.workspaces.id
  description = "Outbound allow"
}

resource "aws_security_group_rule" "ad" {
  type              = "egress"
  from_port         = -1
  to_port           = -1
  description = "allow-ad-egress"
  protocol          = "all"
  source_security_group_id = aws_directory_service_directory.aws-managed-ad.security_group_id
  security_group_id = aws_security_group.workspaces.id
}
