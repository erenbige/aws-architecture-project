# 1. En güncel Amazon Linux 2023 imajını (İşletim Sistemi) otomatik bulur
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# ==========================================
# INTERNAL ALB (İç Yük Dengeleyici)
# ==========================================
resource "aws_lb" "internal_alb" {
   name               = "app-backend-alb"
  internal           = true # İnternete kapalı! Sadece Nginx üzerinden erişilir.
  load_balancer_type = "application"
  security_groups    = [aws_security_group.internal_alb_sg.id]
  subnets            = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  tags = {
    Name = "internal-alb"
  }
}

resource "aws_lb_target_group" "app_tg" {
  name     = "app-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
  }
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# ==========================================
# AUTO SCALING GROUP & DOCKERIZED APP
# ==========================================
resource "aws_launch_template" "app_lt" {
  name_prefix   = "hello-world-app-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  # Docker kuran ve Hello World imajını çalıştıran Başlangıç Scripti (User Data)
  user_data = base64encode(<<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y docker
              systemctl enable docker
              systemctl start docker
              # Basit bir Hello World Nginx container'ı ayağa kaldırıyoruz
              docker run -d -p 80:8000 crccheck/hello-world
              EOF
  )
}

resource "aws_autoscaling_group" "app_asg" {
  name                = "hello-world-asg"
  vpc_zone_identifier = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  target_group_arns   = [aws_lb_target_group.app_tg.arn]
  
  desired_capacity    = 2
  min_size            = 2
  max_size            = 4

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "HelloWorld-Docker-Instance"
    propagate_at_launch = true
  }
}

# ==========================================
# NGINX PROXY SERVER (EC2)
# ==========================================
resource "aws_instance" "nginx_proxy" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public_subnet.id
  
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]

  # Nginx kuran ve trafiği dinamik olarak Internal ALB'ye yönlendiren Script
  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y nginx
              
              # Proxy konfigürasyonunu Internal ALB'nin DNS adresine göre oluşturuyoruz
              cat <<EOT > /etc/nginx/conf.d/proxy.conf
              server {
                  listen 80;
                  location / {
                      proxy_pass http://${aws_lb.internal_alb.dns_name};
                      proxy_set_header Host \$host;
                      proxy_set_header X-Real-IP \$remote_addr;
                  }
              }
              EOT
              
              systemctl enable nginx
              systemctl start nginx
              EOF

  tags = {
    Name = "nginx-proxy-server"
  }
}