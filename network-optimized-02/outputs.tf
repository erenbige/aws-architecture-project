output "alb_dns_name" {
  description = "Application Load Balancer DNS Adresi"
  value       = aws_lb.main.dns_name # 'main' kısmını lb kaynağına verdiğin isimle değiştir
}