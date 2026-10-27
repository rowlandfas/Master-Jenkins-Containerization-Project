#!/bin/bash
# Creates the S3 bucket that stores the Terraform state for this project.
# Run this ONCE, before the first `terraform init`. The bucket is created
# outside Terraform on purpose, so `terraform destroy` can never delete it.
#
# Usage: ./create-s3-bucket.sh
# Uses the AWS profile in $AWS_PROFILE, or "cloudhight" if it isn't set.

set -euo pipefail

BUCKET_NAME="oct-2026-state-s3bucket"
AWS_REGION="eu-west-3"
AWS_PROFILE="${AWS_PROFILE:-cloudhight}"

echo "Using AWS profile: $AWS_PROFILE"
aws sts get-caller-identity --profile "$AWS_PROFILE" --query 'Account' --output text

# 1. Create the bucket (skip if it already exists)
echo "Creating S3 bucket $BUCKET_NAME..."
if aws s3api head-bucket --bucket "$BUCKET_NAME" --profile "$AWS_PROFILE" 2>/dev/null; then
  echo "Bucket already exists, skipping creation."
else
  aws s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region "$AWS_REGION" \
    --profile "$AWS_PROFILE" \
    --create-bucket-configuration LocationConstraint="$AWS_REGION"
  echo "Bucket created."
fi

# 2. Versioning: every change to the state is kept, so a bad state can be rolled back
echo "Enabling versioning..."
aws s3api put-bucket-versioning \
  --bucket "$BUCKET_NAME" \
  --profile "$AWS_PROFILE" \
  --versioning-configuration Status=Enabled

# 3. Encryption: the state file contains secrets such as the generated private key
echo "Enabling encryption..."
aws s3api put-bucket-encryption \
  --bucket "$BUCKET_NAME" \
  --profile "$AWS_PROFILE" \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": { "SSEAlgorithm": "AES256" },
      "BucketKeyEnabled": true
    }]
  }'

# 4. Block all public access
echo "Blocking public access..."
aws s3api put-public-access-block \
  --bucket "$BUCKET_NAME" \
  --profile "$AWS_PROFILE" \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

# 5. Refuse any connection that isn't encrypted (HTTPS only)
echo "Requiring HTTPS..."
aws s3api put-bucket-policy \
  --bucket "$BUCKET_NAME" \
  --profile "$AWS_PROFILE" \
  --policy "{
    \"Version\": \"2012-10-17\",
    \"Statement\": [{
      \"Sid\": \"DenyInsecureTransport\",
      \"Effect\": \"Deny\",
      \"Principal\": \"*\",
      \"Action\": \"s3:*\",
      \"Resource\": [\"arn:aws:s3:::$BUCKET_NAME\", \"arn:aws:s3:::$BUCKET_NAME/*\"],
      \"Condition\": { \"Bool\": { \"aws:SecureTransport\": \"false\" } }
    }]
  }"

# 6. Tag the bucket so it shows up with the rest of the project
aws s3api put-bucket-tagging \
  --bucket "$BUCKET_NAME" \
  --profile "$AWS_PROFILE" \
  --tagging 'TagSet=[{Key=Name,Value=19thoct-terraform-state},{Key=Project,Value=19thoct}]'

echo "Done. State bucket $BUCKET_NAME is ready."
echo "Next: terraform init (or terraform init -migrate-state if a local state already exists)."
