resource "aws_iam_user" "dev_view" {
  name = "bedrock-dev-view"
  tags = {
    Project = "karatu-2025-capstone"
  }
}

resource "aws_iam_user_policy_attachment" "dev_view_readonly" {
  user       = aws_iam_user.dev_view.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_user_policy" "dev_view_s3_put" {
  name = "bedrock-assets-put-object"
  user = aws_iam_user.dev_view.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "s3:PutObject"
      Resource = "arn:aws:s3:::bedrock-assets-${var.student_id}/*"
    }]
  })
}
