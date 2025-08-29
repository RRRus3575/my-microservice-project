data "aws_caller_identity" "current" {}


resource "aws_ecr_repository" "this" {
name = var.ecr_name
image_tag_mutability = "MUTABLE" 


image_scanning_configuration {
scan_on_push = var.scan_on_push
}


encryption_configuration {
encryption_type = "AES256"
}


tags = {
Name = var.ecr_name
}
}


resource "aws_ecr_repository_policy" "this" {
repository = aws_ecr_repository.this.name
policy = jsonencode({
Version = "2012-10-17",
Statement = [
{
Sid = "AllowRootInAccount",
Effect = "Allow",
Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" },
Action = [
"ecr:GetDownloadUrlForLayer",
"ecr:BatchGetImage",
"ecr:BatchCheckLayerAvailability",
"ecr:PutImage",
"ecr:InitiateLayerUpload",
"ecr:UploadLayerPart",
"ecr:CompleteLayerUpload",
"ecr:DescribeRepositories",
"ecr:DescribeImages",
"ecr:ListImages",
"ecr:GetRepositoryPolicy"
]
}
]
})
}


