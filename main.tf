resource "aws_s3_bucket" "documents" {
  bucket = var.documents_bucket_name

  tags = {
    Name        = var.documents_bucket_name
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "documents" {
  bucket = aws_s3_bucket.documents.id

  versioning_configuration {
    status = "Enabled"
  }
}
