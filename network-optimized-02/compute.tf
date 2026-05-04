# Application Load Balancer
resource "aws_lb" "alb" {
  name               = "optimized-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.pub_1.id, aws_subnet.pub_2.id]
}

resource "aws_lb_target_group" "tg" {
  name     = "optimized-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.opt_vpc.id
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_launch_template" "lt" {
  name_prefix   = "opt-app-"
  image_id      = "ami-071878317c449ae48" # Amazon Linux 2023 - eu-central-1
  instance_type = "t2.micro"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ec2_sg.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Network Optimized Architecture</h1><p>Running on Public Subnets without NAT</p>" > /var/www/html/index.html
              EOF
  )
}

# Auto Scaling Group
resource "aws_autoscaling_group" "asg" {
  desired_capacity    = 1
  max_size            = 2
  min_size            = 1
  target_group_arns   = [aws_lb_target_group.tg.arn]
  vpc_zone_identifier = [aws_subnet.pub_1.id, aws_subnet.pub_2.id]

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }
}