output "nginx_public_ip" {
  description = "Tarayiciya yapistirip test edecegimiz Nginx IP Adresi"
  value       = aws_instance.nginx_proxy.public_ip
}