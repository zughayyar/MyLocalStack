data "archive_file" "confirm_upload" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/confirm_upload"
  output_path = "${path.module}/build/confirm_upload.zip"
}

resource "aws_iam_role" "confirm_upload" {
  name = "confirm-upload-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "confirm_upload_logs" {
  role       = aws_iam_role.confirm_upload.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "confirm_upload" {
  function_name    = "confirm-upload"
  filename         = data.archive_file.confirm_upload.output_path
  source_code_hash = data.archive_file.confirm_upload.output_base64sha256
  role             = aws_iam_role.confirm_upload.arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.12"
  timeout          = 30

  environment {
    variables = {
      LOG_LEVEL = "INFO"
    }
  }
}

resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.confirm_upload.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.documents.arn
}

resource "aws_s3_bucket_notification" "documents" {
  bucket = aws_s3_bucket.documents.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.confirm_upload.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "pending/"
  }

  depends_on = [aws_lambda_permission.allow_s3_invoke]
}
