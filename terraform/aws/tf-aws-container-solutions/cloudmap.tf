resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = "${var.domain_name}.local"
  description = var.project_name
  vpc         = data.terraform_remote_state.vpc.outputs.vpc_id
}

resource "aws_service_discovery_service" "main" {
  name = var.project_name

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}