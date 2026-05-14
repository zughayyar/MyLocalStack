resource "aws_sqs_queue" "upload_events_dlq" {
  name                      = "${var.environment}-upload-events-dlq"
  message_retention_seconds = 1209600
}

resource "aws_sqs_queue" "upload_events" {
  name                       = "${var.environment}-upload-events"
  message_retention_seconds  = 86400
  visibility_timeout_seconds = 120

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.upload_events_dlq.arn
    maxReceiveCount     = 3
  })
}
