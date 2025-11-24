output "bucket_id" {
  description = "The name of the bucket"
  value       = aws_s3_bucket.main.id
}

output "bucket_arn" {
  description = "The ARN of the bucket"
  value       = aws_s3_bucket.main.arn
}

output "bucket_domain_name" {
  description = "The domain name of the bucket"
  value       = aws_s3_bucket.main.bucket_domain_name
}

output "ses_sender_email" {
  description = "Verified SES sender email"
  value       = aws_ses_email_identity.sender.email
}

output "ses_sender_arn" {
  description = "ARN of the verified sender identity"
  value       = aws_ses_email_identity.sender.arn
}

output "ses_template_name" {
  description = "Name of the SES email template"
  value       = aws_ses_template.example.name
}
