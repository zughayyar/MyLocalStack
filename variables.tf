variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ca-central-1"
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "my-local-bucket"
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "local"
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
