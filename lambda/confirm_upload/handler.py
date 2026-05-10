"""
S3 ObjectCreated handler — fires when a presigned upload lands under the
`pending/` prefix in the documents bucket.

Parses the S3 event, identifies the upload kind (document vs. generic
resource), and publishes a normalized message to the upload-events SQS
queue for the backend listener (SQSConsumer) to confirm-upload async.
"""

import json
import logging
import os
import urllib.parse
from pathlib import PurePosixPath

import boto3

logger = logging.getLogger()
logger.setLevel(os.environ.get("LOG_LEVEL", "INFO"))

_sqs = boto3.client("sqs", endpoint_url=os.environ.get("AWS_ENDPOINT_URL"))
_QUEUE_URL = os.environ["SQS_QUEUE_URL"]


def _parse_key(key: str) -> dict:
    """
    Map an S3 key to a normalized payload.

    Recognized shapes (always under a `pending/` prefix):
      - documents:
            pending/{org_id}/documents/uploads/document/{date}/{document_id}/{resource_id}{ext}
      - legacy resource (image/audio/video, also used by older documents):
            pending/{org_id}/{location|shared}/{origin}/{type}/{date}/{resource_id}{ext}

    Returns a dict including `kind` so the consumer can branch:
      - "document_pending_upload" — has org_id, document_id, resource_id
      - "resource_pending_upload" — has org_id, resource_id (legacy)
      - "unknown" — does not match either shape
    """
    parts = PurePosixPath(key).parts
    if not parts or parts[0] != "pending":
        return {"kind": "unknown"}

    # Documents shape: 8 parts, parts[2]/[3]/[4] are literals
    if (
        len(parts) == 8
        and parts[2] == "documents"
        and parts[3] == "uploads"
        and parts[4] == "document"
    ):
        return {
            "kind": "document_pending_upload",
            "org_id": parts[1],
            "resource_type": "document",
            "date": parts[5],
            "document_id": parts[6],
            "resource_id": PurePosixPath(parts[7]).stem,
        }

    # Legacy resource shape: 7 parts
    if len(parts) == 7:
        return {
            "kind": "resource_pending_upload",
            "org_id": parts[1],
            "location": parts[2],
            "origin": parts[3],
            "resource_type": parts[4],
            "date": parts[5],
            "resource_id": PurePosixPath(parts[6]).stem,
        }

    return {"kind": "unknown"}


def _build_message(record: dict) -> dict:
    s3 = record.get("s3", {})
    bucket = s3.get("bucket", {}).get("name")
    raw_key = s3.get("object", {}).get("key", "")
    key = urllib.parse.unquote_plus(raw_key)
    size = s3.get("object", {}).get("size")
    etag = s3.get("object", {}).get("eTag")
    event_name = record.get("eventName")

    parsed = _parse_key(key)
    return {
        "event_name": event_name,
        "bucket": bucket,
        "key": key,
        "size": size,
        "etag": etag,
        **parsed,
    }


def lambda_handler(event, context):
    records = event.get("Records", [])
    logger.info("Received %d S3 record(s)", len(records))

    processed = []
    for record in records:
        msg = _build_message(record)
        logger.info("upload_complete %s", json.dumps(msg))
        _sqs.send_message(QueueUrl=_QUEUE_URL, MessageBody=json.dumps(msg))
        processed.append(msg)

    return {
        "statusCode": 200,
        "body": json.dumps({"processed": len(processed), "records": processed}),
    }
