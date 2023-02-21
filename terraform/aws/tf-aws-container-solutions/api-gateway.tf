###################
# HTTP API Gateway
###################

module "api_gateway" {
  source  = "terraform-aws-modules/apigateway-v2/aws"
  version = "2.2.2"

  name          = "${var.env}-api-gateway"
  description   = "cms5poc HTTP API Gateway"
  protocol_type = "HTTP"

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

#   mutual_tls_authentication = {
#     truststore_uri     = "s3://${aws_s3_bucket.truststore.bucket}/${aws_s3_object.truststore.id}"
#     truststore_version = aws_s3_object.truststore.version_id
#   }

  domain_name                 = "apigateway.${var.domain_name}"
  domain_name_certificate_arn = aws_acm_certificate.cms5poc_online.arn

  default_stage_access_log_destination_arn = aws_cloudwatch_log_group.api_gateway.arn
  default_stage_access_log_format          = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId $context.integrationErrorMessage"

  default_route_settings = {
    detailed_metrics_enabled = true
    throttling_burst_limit   = 100
    throttling_rate_limit    = 100
  }

#   authorizers = {
#     "cognito" = {
#       authorizer_type  = "JWT"
#       identity_sources = "$request.header.Authorization"
#       name             = "cognito"
#       audience         = ["d6a38afd-45d6-4874-d1aa-3c5c558aqcc2"]
#       issuer           = "https://${aws_cognito_user_pool.this.endpoint}"
#     }
#   }

integrations = {
    "GET /tasks-api/info" = {
      connection_type    = "VPC_LINK"
      vpc_link           = "my-vpc"
      integration_uri    = aws_lb_listener.prod["tasks-api"].arn
      integration_type   = "HTTP_PROXY"
      integration_method = "GET"
      request_parameters     = {
        "overwrite:path" = "/info" 
      }
    }

    "GET /tasks-scheduler/info" = {
      connection_type    = "VPC_LINK"
      vpc_link           = "my-vpc"
      integration_uri    = aws_lb_listener.prod["tasks-scheduler"].arn
      integration_type   = "HTTP_PROXY"
      integration_method = "GET"
      request_parameters     = {
        "overwrite:path" = "/info" 
    }
    }

    "GET /tasks-subscriber/info" = {
      connection_type    = "VPC_LINK"
      vpc_link           = "my-vpc"
      integration_uri    = aws_lb_listener.prod["tasks-subscriber"].arn
      integration_type   = "HTTP_PROXY"
      integration_method = "GET"
      request_parameters     = {
        "overwrite:path" = "/info" 
      }
}
}

  vpc_links = {
    my-vpc = {
      name               = "${var.project_name}-vpc-link-${var.env}"
      security_group_ids = [module.api_gateway_sg.security_group_id]
      subnet_ids         = data.terraform_remote_state.vpc.outputs.private_subnets
    }
  }
  

    # "GET /some-route-with-authorizer" = {
    #   lambda_arn             = module.lambda_function.lambda_function_arn
    #   payload_format_version = "2.0"
    #   authorizer_key         = "cognito"
    # }

    # "GET /some-route-with-authorizer-and-scope" = {
    #   lambda_arn             = module.lambda_function.lambda_function_arn
    #   payload_format_version = "2.0"
    #   authorization_type     = "JWT"
    #   authorizer_key         = "cognito"
    #   authorization_scopes   = "tf/something.relevant.read,tf/something.relevant.write" # Should comply with the resource server configuration part of the cognito user pool
    # }

    # "GET /some-route-with-authorizer-and-different-scope" = {
    #   lambda_arn             = module.lambda_function.lambda_function_arn
    #   payload_format_version = "2.0"
    #   authorization_type     = "JWT"
    #   authorizer_key         = "cognito"
    #   authorization_scopes   = "tf/something.relevant.write" # Should comply with the resource server configuration part of the cognito user pool
    # }

    # "POST /start-step-function" = {
    #   integration_type    = "AWS_PROXY"
    #   integration_subtype = "StepFunctions-StartExecution"
    #   credentials_arn     = module.step_function.role_arn

    #   # Note: jsonencode is used to pass argument as a string
    #   request_parameters = jsonencode({
    #     StateMachineArn = module.step_function.state_machine_arn
    #   })

    #   payload_format_version = "1.0"
    #   timeout_milliseconds   = 12000
    # }

    # "$default" = {
    #   lambda_arn = module.lambda_function.lambda_function_arn
    #   tls_config = jsonencode({
    #     server_name_to_verify = local.domain_name
    #   })

    #   response_parameters = jsonencode([
    #     {
    #       status_code = 500
    #       mappings = {
    #         "append:header.header1" = "$context.requestId"
    #         "overwrite:statuscode"  = "403"
    #       }
    #     },
    #     {
    #       status_code = 404
    #       mappings = {
    #         "append:header.error" = "$stageVariables.environmentId"
    #       }
    #     }
    #   ])
    # }
# }

#   body = templatefile("api.yaml", {
#     example_function_arn = module.lambda_function.lambda_function_arn
#   })

  tags = {
    Name = "${var.project_name}-api-gateway-${var.env}"
  }
}

resource "aws_cloudwatch_log_group" "api_gateway" {
  #checkov:skip=CKV_AWS_158: KMS will be added post PoC
  #checkov:skip=CKV_AWS_66: Cloudwatch Logs retention not required for PoC
  name = "${var.project_name}-${var.env}-api-gateway-logs"
}

// Security Group for the API Gateway
module "api_gateway_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${var.project_name}-api-gateway-sg-${var.env}"
  description = "${var.project_name} API Gateway group"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress_cidr_blocks = local.azure_allow_list
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]

  egress_rules = ["all-all"]
}