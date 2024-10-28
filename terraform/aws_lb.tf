resource "aws_security_group" "internal_lb_sg" {
  name        = "int-lb-${var.project}-${var.environment}"
  description = "Security Group for Internal Load Balancer for ECS"
  vpc_id      = aws_vpc.anaexames.id

  # Permitir tráfego de entrada na porta 443 para o LB (HTTPS)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # Ajuste conforme a CIDR da sua VPC para permitir tráfego interno
  }
}

resource "aws_lb" "apigw_ecs_internal_lb" {
  name               = "int-lb-${var.project}-${var.environment}"
  internal           = true  
  load_balancer_type = "network" 
  subnets            = [aws_subnet.private_a.id]
  security_groups    = [aws_security_group.internal_lb_sg.id]
}
