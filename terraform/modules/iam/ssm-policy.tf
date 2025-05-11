resource "aws_iam_policy" "ssm_read_secrets" {
  name        = "${var.app_name}-ssm-read"
  description = "Allow ECS task to read DB secrets from SSM"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ],
        Effect   = "Allow",
        Resource = [
          "arn:aws:ssm:*:*:parameter/cloud-cost-dashboard/*"
        ]
      }
    ]
  })
}
