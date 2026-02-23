resource "aws_ecr_repository" "strapi" {
  name                 = var.ecr_repo_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = { Name = var.ecr_repo_name }
}

output "ecr_repository_url" {
  value = aws_ecr_repository.strapi.repository_url
}
