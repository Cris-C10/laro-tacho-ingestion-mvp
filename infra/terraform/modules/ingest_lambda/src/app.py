# Import OS module to read environment variables
import os

# Used to generate UTC timestamps
from datetime import datetime, timezone

# AWS SDK for Python
import boto3

# Create DynamoDB client
ddb = boto3.client("dynamodb")

# Create S3 client
s3 = boto3.client("s3")

# Read environment variables that Terraform will inject into Lambda
LEDGER_TABLE = os.environ["LEDGER_TABLE"]
RAW_BUCKET = os.environ["RAW_BUCKET"]


# Helper function: returns current UTC time in ISO format
# Example: 2026-02-22T12:34:56.123456+00:00
def iso_now():
    return datetime.now(timezone.utc).isoformat()


# This is the Lambda entry point
# AWS calls this function automatically
# event = input payload
# context = AWS runtime metadata (we don't use it yet)
def lambda_handler(event, context):

    # For now we expect manual test input like:
    # { "object_key": "test.ddd" }
    object_key = event.get("object_key")

    # If caller didn't provide object_key, return error
    if not object_key:
        return {"error": "object_key required"}

    # ---------------------------------------------------------
    # STEP 1 — Write initial ledger record with status RECEIVED
    # ---------------------------------------------------------
    ddb.put_item(
        TableName=LEDGER_TABLE,
        Item={
            # Primary key
            "object_key": {"S": object_key},

            # Processing state
            "status": {"S": "RECEIVED"},

            # Timestamp when ingestion started
            "received_at": {"S": iso_now()},
        },
    )

    # ---------------------------------------------------------
    # STEP 2 — Try accessing the object in S3
    # We are NOT downloading it.
    # head_object just checks if it exists + we have permission.
    # ---------------------------------------------------------
    try:
        s3.head_object(Bucket=RAW_BUCKET, Key=object_key)

        # -----------------------------------------------------
        # STEP 3 — If S3 access worked → mark PROCESSED
        # -----------------------------------------------------
        ddb.update_item(
            TableName=LEDGER_TABLE,
            Key={"object_key": {"S": object_key}},
            UpdateExpression="SET #s = :s",
            ExpressionAttributeNames={"#s": "status"},
            ExpressionAttributeValues={":s": {"S": "PROCESSED"}},
        )

        return {"ok": True, "object_key": object_key}

    except Exception as e:

        # -----------------------------------------------------
        # If anything fails → mark FAILED
        # -----------------------------------------------------
        ddb.update_item(
            TableName=LEDGER_TABLE,
            Key={"object_key": {"S": object_key}},
            UpdateExpression="SET #s = :s",
            ExpressionAttributeNames={"#s": "status"},
            ExpressionAttributeValues={":s": {"S": "FAILED"}},
        )

        # Re-throw error so Lambda logs show failure
        raise e