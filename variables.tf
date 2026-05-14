variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "documents_bucket_name" {
  description = "S3 bucket for SerenityGX document uploads (matches backend RESOURCES_S3_BUCKET)"
  type        = string
  default     = "serenitygx-dev"
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "dev"
}

variable "ses_sender_email" {
  description = "Sender email address for SES"
  type        = string
  default     = "sender@example.com"
}

variable "ses_recipient_email" {
  description = "Recipient email address for SES testing"
  type        = string
  default     = "recipient@example.com"
}
