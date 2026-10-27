#!/bin/bash
# Deletes the Terraform state bucket and EVERY version of the state inside it.
# Run this LAST, only after `terraform destroy` has finished, or Terraform
# loses track of everything it built and those resources keep costing money.
#
# Usage: ./delete-s3-bucket.sh

set -euo pipefail

BUCKET_NAME="oct-2026-state-s3bucket"
AWS_REGION="eu-west-3"
AWS_PROFILE="${AWS_PROFILE:-cloudhight}"

command -v jq >/dev/null || { echo "jq is required: brew install jq"; exit 1; }

echo "This deletes $BUCKET_NAME and all Terraform state history in it."
read -r -p "Has terraform destroy already completed? Type 'yes' to continue: " CONFIRM
[ "$CONFIRM" = "yes" ] || { echo "Cancelled."; exit 1; }

# Versioned buckets keep every old version, so all versions and delete markers
# must be removed before the bucket can be deleted. Done in batches of 1000.
while true; do
  BATCH=$(aws s3api list-object-versions \
    --bucket "$BUCKET_NAME" \
    --profile "$AWS_PROFILE" \
    --max-items 1000 \
    --output json | jq '{Objects: ([.Versions[]?, .DeleteMarkers[]?] | map({Key: .Key, VersionId: .VersionId})), Quiet: true}')

  COUNT=$(echo "$BATCH" | jq '.Objects | length')
  [ "$COUNT" -eq 0 ] && break

  echo "Deleting $COUNT object versions..."
  aws s3api delete-objects \
    --bucket "$BUCKET_NAME" \
    --profile "$AWS_PROFILE" \
    --delete "$BATCH" >/dev/null
done

echo "Deleting bucket $BUCKET_NAME..."
aws s3api delete-bucket \
  --bucket "$BUCKET_NAME" \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE"

echo "Bucket $BUCKET_NAME deleted."
