resource "aws_ses_email_identity" "sender" {
  email = var.ses_sender_email
}

resource "aws_ses_email_identity" "recipient" {
  email = var.ses_recipient_email
}

resource "aws_ses_template" "example" {
  name    = "example-template"
  subject = "Hello {{name}}"
  html    = "<h1>Hello {{name}}</h1><p>This is a test email from LocalStack SES.</p>"
  text    = "Hello {{name}}, This is a test email from LocalStack SES."
}
