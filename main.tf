provider "aws" {
  region = var.region
}

# 1. The Core S3 Bucket Resource
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags   = var.tags
}

# 2. Enforce VERSIONING (OPA Policy Check 1: Status must be "Enabled")
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

# 3. Enforce DEFAULT ENCRYPTION (OPA Policy Check 2: Algorithm must be AES256 or aws:kms)
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 4. Enforce BLOCK PUBLIC ACCESS (OPA Policy Check 3: All four fields must be true)
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# 5. Enforce LIFECYCLE CONFIGURATION (OPA Policy Check 4: Must exist and be Enabled)
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "version-management"
    status = "Enabled"

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    expiration {
      days = 365
    }
  }
}
