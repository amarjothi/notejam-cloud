resource "aws_workspaces_workspace" "template_workspace" {
  #checkov:skip=CKV_AWS_155:The workspace user volume needs to be unencrypted in order to have an image captured from it
  #checkov:skip=CKV_AWS_156:The workspace root volume needs to be unencrypted in order to have an image captured from it
  directory_id = aws_workspaces_directory.workspaces-directory.id
  bundle_id = var.workspace_bundle_ids["windows10"]
  user_name = "template.user" 
  # Disable encryption because it can't be on to create an image from
  root_volume_encryption_enabled = false
  user_volume_encryption_enabled = false
  #volume_encryption_key = aws_kms_key.workspaces-kms.arn  
  
  workspace_properties {
    compute_type_name = "STANDARD"
    user_volume_size_gib = 50
    root_volume_size_gib = 80
    running_mode = "AUTO_STOP"
    running_mode_auto_stop_timeout_in_minutes = 60
  }  
  
  tags = {
    Name = "${var.project_name}-template-workspace${var.env}"
    Environment = var.env
  }  
  
  depends_on = [
    aws_iam_role.workspaces-default,
    aws_workspaces_directory.workspaces-directory
  ]
}