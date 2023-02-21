# output "ec2_instance_ids" {
#     description = "Output the instance ids created from the ec2 module"
#     value = { for k, v in module.ec2 : k => v.id }
# }

# output "workspace_directory_name" {
#     description = "Output the name of the workspace directory"
#     value = aws_workspaces_directory.workspaces-directory.directory_name
# }
# output "workspace_directory_id" {
#     description = "Output the id of the workspace directory"
#     value = aws_workspaces_directory.workspaces-directory.id
# }

# output "registration_code" {
#     description = "Output the registration code for the workspace directory"
#     value = aws_workspaces_directory.workspaces-directory.registration_code
# }

# // Output for Workspaces Security Group
# output "security_group_id" {
#     description = "Output the security group id for the workspaces"
#     value = aws_security_group.workspaces.id
# }