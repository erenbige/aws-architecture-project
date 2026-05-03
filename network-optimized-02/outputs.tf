output "alb_url" {
  description = "Network Optimized Mimari Linki"
  value       = "http://${aws_lb.alb.dns_name}"
}