###############################
# GitHub OIDC Provider (once)
###############################
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

###############################
# Role assumed by GitHub Actions
###############################
data "aws_iam_policy_document" "gh_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repo}:*"]
    }
  }
}

resource "aws_iam_role" "github_oidc" {
  name               = "${var.app_name}-gh-deploy"
  assume_role_policy = data.aws_iam_policy_document.gh_assume.json
}

# Grant just what the pipeline needs: ECR push + ECS deploy + logs
resource "aws_iam_policy" "gh_policy" {
  name   = "${var.app_name}-gh-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ], Effect = "Allow", Resource = "*" },
      { Action = [
          "ecs:DescribeServices",
          "ecs:UpdateService",
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition"
        ], Effect = "Allow", Resource = "*" },
      { Action = [
          "iam:PassRole"
        ], Effect = "Allow", Resource = aws_iam_role.exec.arn }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "gh_attach" {
  role       = aws_iam_role.github_oidc.name
  policy_arn = aws_iam_policy.gh_policy.arn
}

output "github_role_arn" {
  value = aws_iam_role.github_oidc.arn
}
