provider "aws" {
  region = var.region
}

# Core S3 bucket resource
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags   = var.tags

  # Enable versioning
  versioning {
    enabled = true
  }

  # Enable lifecycle management
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

  # Enable server-side encryption with KMS
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = "alias/aws/s3"
      }
    }
  }
}

# Enforce public access block (REQUIRED for OPA compliance)
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}
