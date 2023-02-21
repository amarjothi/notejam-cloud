## ECR outputs
// Output the name of each ECR repository
output "ecr_repositories_name" {
  value = { for k, v in aws_ecr_repository.ecs_services : k => v.name }
}

// Output each of the ECS services
output "ecs_services_name" {
  value = { for k, v in aws_ecs_service.ecs_services : k => v.name }
}

// Output each of the ECS Load balancers

output "ecs_load_balancers_name" {
  value = { for k, v in aws_lb.ecs_service : k => v.name }
}
output "ecs_load_balancers_dns_name" {
  value = { for k, v in aws_lb.ecs_service : k => v.dns_name }
}

// Output each of the ECS target groups
output "ecs_target_groups" {
  value = { for k, v in aws_lb_target_group.target_group : k => v.arn }
}

// Output arn of each task definition
output "ecs_task_definition_arn" {
  value = { for k, v in aws_ecs_task_definition.ecs_task : k => v.arn }
}

// Output API Gateway ARN
output "api_gateway_endpoint" {
  value = module.api_gateway.apigatewayv2_api_api_endpoint
}

//Output the API Gateway ARN
output "api_gateway_arn" {
  value = module.api_gateway.apigatewayv2_api_arn
}

output "test_output" {
   value = local.merged_list
}