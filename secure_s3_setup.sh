#!/bin/bash

# Define bucket names
BUCKET_NAME="secure-s3-pierre"
LOG_BUCKET="cloudtrail-logs-pierre"

# Create an S3 bucket
aws s3api create-bucket --bucket $BUCKET_NAME --region us-east-1

# Block public access
aws s3api put-public-access-block --bucket $BUCKET_NAME --public-access-block-configuration '{
  "BlockPublicAcls": true,
  "IgnorePublicAcls": true,
  "BlockPublicPolicy": true,
  "RestrictPublicBuckets": true
}'

# Enforce encryption (AES-256)
aws s3api put-bucket-encryption --bucket $BUCKET_NAME --server-side-encryption-configuration '{
  "Rules": [{
    "ApplyServerSideEncryptionByDefault": {
      "SSEAlgorithm": "AES256"
    }
  }]
}'

# Enforce HTTPS-only access
aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy '{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowOnlySecureTransport",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": ["arn:aws:s3:::'$BUCKET_NAME'", "arn:aws:s3:::'$BUCKET_NAME'/*"],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}'

# Create a CloudTrail logging bucket
aws s3api create-bucket --bucket $LOG_BUCKET --region us-east-1

# Enable CloudTrail logging
aws cloudtrail create-trail --name SecureS3Trail --s3-bucket-name $LOG_BUCKET
aws cloudtrail start-logging --name SecureS3Trail

echo "✅ Secure AWS S3 bucket setup completed!"