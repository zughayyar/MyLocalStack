"""
S3 ObjectCreated handler — fires when a presigned upload lands under the
`pending/` prefix in the documents bucket.

This is a placeholder: it parses the S3 event and logs a structured line.
Later this can be extended to either
  - publish to SQS for async processing, or
  - call the backend's confirm-upload endpoint directly.
"""

import json
import logging
import os
import urllib.parse
from pathlib import PurePosixPath

logger = logging.getLogger()
logger.setLevel(os.environ.get("LOG_LEVEL", "INFO"))


def _parse_record(record):
    s3 = record.get("s3", {})
    bucket = s3.get("bucket", {}).get("name")
    raw_key = s3.get("object", {}).get("key", "")
    key = urllib.parse.unquote_plus(raw_key)
    size = s3.get("object", {}).get("size")
    etag = s3.get("object", {}).get("eTag")
    event_name = record.get("eventName")

    # Key convention from the backend resource service:
    #   pending/{org_id}/{location|shared}/{origin}/{type}/{YYYY-MM-DD}/{resource_id}{.ext}
    parts = PurePosixPath(key).parts
    parsed = {}
    if len(parts) >= 8 and parts[0] == "pending":
        parsed = {
            "org_id": parts[1],
            "location": parts[2],
            "origin": parts[3],
            "resource_type": parts[4],
            "date": parts[5],
            "resource_id": PurePosixPath(parts[7]).stem,
        }

    return {
        "event_name": event_name,
        "bucket": bucket,
        "key": key,
        "size": size,
        "etag": etag,
        "parsed": parsed,
    }


def lambda_handler(event, context):
    records = event.get("Records", [])
    logger.info("Received %d S3 record(s)", len(records))

    processed = []
    for record in records:
        info = _parse_record(record)
        logger.info("upload_complete %s", json.dumps(info))
        processed.append(info)

    return {
        "statusCode": 200,
        "body": json.dumps({"processed": len(processed), "records": processed}),
    }
