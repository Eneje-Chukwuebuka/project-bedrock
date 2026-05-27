# ─── S3 BUCKET ──────────────────────────────────────────
resource "aws_s3_bucket" "assets" {
  bucket = "bedrock-assets-${var.student_id}"

  tags = merge(var.tags, {
    Name = "bedrock-assets-${var.student_id}"
  })
}

resource "aws_s3_bucket_public_access_block" "assets" {
  bucket = aws_s3_bucket.assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ─── LAMBDA IAM ROLE ────────────────────────────────────
resource "aws_iam_role" "lambda" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda.name
}

# ─── LAMBDA FUNCTION ────────────────────────────────────
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.root}/../lambda/handler.py"
  output_path = "${path.root}/../lambda/handler.zip"
}

resource "aws_lambda_function" "asset_processor" {
  filename         = data.archive_file.lambda.output_path
  function_name    = "bedrock-asset-processor"
  role             = aws_iam_role.lambda.arn
  handler          = "handler.handler"
  runtime          = "python3.12"
  source_code_hash = data.archive_file.lambda.output_base64sha256

  tags = merge(var.tags, {
    Name = "bedrock-asset-processor"
  })
}

# ─── S3 TRIGGER PERMISSION ──────────────────────────────
resource "aws_lambda_permission" "s3_trigger" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.asset_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.assets.arn
}

# ─── S3 EVENT NOTIFICATION ──────────────────────────────
resource "aws_s3_bucket_notification" "asset_upload" {
  bucket = aws_s3_bucket.assets.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.asset_processor.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.s3_trigger]
}