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

resource "aws_s3_bucket_lifecycle_configuration" "documents" {
  bucket = aws_s3_bucket.documents.id

  rule {
    id     = "expire-pending-uploads"
    status = "Enabled"

    filter {
      prefix = "pending/"
    }

    expiration {
      days = 1
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}
