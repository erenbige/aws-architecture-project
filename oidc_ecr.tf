# 1. ECR Repository - Docker imajlarının saklanacağı yer
resource "aws_ecr_repository" "hello_world_app" {
  name                 = "hello-world-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# 2. OIDC Identity Provider - GitHub ile güven köprüsü
# Not: Eğer hata alırsan terminalden 'terraform import' komutunu çalıştıracağız
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# 3. GitHub Actions'ın AWS'e giriş yapacağı IAM Rolü
resource "aws_iam_role" "github_actions_role" {
  name = "github-actions-ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Condition = {
          StringLike = {
            # Sadece senin reponun bu rolü kullanmasına izin veriyoruz
            "token.actions.githubusercontent.com:sub": "repo:erenbige/aws-architecture-project:*"
          }
        }
      }
    ]
  })
}

# 4. Role Yetkisi - ECR'a imaj yükleyebilmesi için gerekli izin
resource "aws_iam_role_policy_attachment" "github_actions_ecr_policy" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

# ÇIKTILAR (Outputs) - GitHub Settings'e eklenecek değerler
output "ecr_repository_url" {
  value = aws_ecr_repository.hello_world_app.repository_url
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions_role.arn
}