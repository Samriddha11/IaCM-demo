provider "aws" {
  region = var.region
}

# 1. The Core S3 Bucket Resource
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags   = var.tags

# Enable versioning
  versioning {
    enabled = true
  }
# Lifecycle management
  lifecycle_rule {
    id      = "version-management"
    enabled = true

    noncurrent_version_transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_expiration {
      days = 90
    }

    expiration {
      days = 365
    }
  }

  # Block all public access
  public_access_block_configuration {
    block_public_acls       = true
    ignore_public_acls      = true
    block_public_policy     = true
    restrict_public_buckets = true
  }
  
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"   # Better than AES256
        kms_master_key_id = "alias/aws/s3" # Default AWS-managed KMS key
      }
    }
  }
}
