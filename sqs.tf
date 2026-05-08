resource "aws_sqs_queue" "upload_events_dlq" {
  name = "upload-events-dlq"
}

resource "aws_sqs_queue" "upload_events" {
  name                       = "upload-events"
  message_retention_seconds  = 86400
  visibility_timeout_seconds = 60

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.upload_events_dlq.arn
    maxReceiveCount     = 3
  })
}
