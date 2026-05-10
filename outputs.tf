output "documents_bucket_id" {
  description = "The name of the documents bucket"
  value       = aws_s3_bucket.documents.id
}

output "documents_bucket_arn" {
  description = "The ARN of the documents bucket"
  value       = aws_s3_bucket.documents.arn
}

output "ses_sender_email" {
  description = "Verified SES sender email"
  value       = aws_ses_email_identity.sender.email
}

output "ses_sender_arn" {
  description = "ARN of the verified sender identity"
  value       = aws_ses_email_identity.sender.arn
}

output "upload_events_queue_url" {
  description = "URL of the upload-events SQS queue"
  value       = aws_sqs_queue.upload_events.url
}

output "upload_events_queue_arn" {
  description = "ARN of the upload-events SQS queue"
  value       = aws_sqs_queue.upload_events.arn
}

