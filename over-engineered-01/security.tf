# 1. Nginx Sunucusu İçin Security Group
resource "aws_security_group" "nginx_sg" {
  name        = "nginx-proxy-sg"
  description = "Security group for public nginx proxy" # Turkce karakterleri sildik
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. Internal ALB İçin Security Group
resource "aws_security_group" "internal_alb_sg" {
  name        = "internal-alb-sg"
  description = "Security group for internal application load balancer"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description     = "HTTP from Nginx SG"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.nginx_sg.id] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. Hello World ASG İçin Security Group
resource "aws_security_group" "app_sg" {
  name        = "hello-world-app-sg"
  description = "Security group for dockerized hello world app"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description     = "HTTP from Internal ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.internal_alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}