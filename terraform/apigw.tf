resource "aws_api_gateway_rest_api" "ecs_restapi" {
  name        = "Api Gw - ${var.project}-${var.environment}"
  description = "API Gateway for Secure ECS Integration"
}

resource "aws_api_gateway_resource" "ecs_resource" {
  rest_api_id = aws_api_gateway_rest_api.ecs_restapi.id
  parent_id   = aws_api_gateway_rest_api.ecs_restapi.root_resource_id
  path_part   = "api"
}

resource "aws_api_gateway_method" "ecs_method" {
  rest_api_id   = aws_api_gateway_rest_api.ecs_restapi.id
  resource_id   = aws_api_gateway_resource.ecs_resource.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_vpc_link" "ecs_vpc_link" {
  name = "ecs-vpc-link-${var.project}-${var.environment}"  
  target_arns = [aws_lb.apigw_ecs_internal_lb.id]
}

resource "aws_api_gateway_integration" "ecs_integration" {
  rest_api_id             = aws_api_gateway_rest_api.ecs_restapi.id
  resource_id             = aws_api_gateway_resource.ecs_resource.id
  http_method             = aws_api_gateway_method.ecs_method.http_method
  type                    = "HTTP_PROXY"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.ecs_vpc_link.id
  uri                     = "http://${aws_lb.apigw_ecs_internal_lb.dns_name}/"  
  integration_http_method = "ANY"
}

resource "aws_api_gateway_deployment" "api_deploy" {
  depends_on = [aws_api_gateway_integration.ecs_integration]
  rest_api_id = aws_api_gateway_rest_api.ecs_restapi.id
  stage_name  = "${var.environment}"
}
