output "frontend_url" {
  description = "Web sitesine erişeceğiniz CloudFront URL'si"
  value       = aws_cloudfront_distribution.cdn.domain_name
}

output "api_endpoint" {
  description = "Backend API servisinin URL'si"
  value       = aws_apigatewayv2_api.api.api_endpoint
}