# main.tf

provider "aws" {
  region = var.region
}

# ---------------------------------------------
# S3 Bucket (All configurations unified)
# ---------------------------------------------
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags   = var.tags

  # ✅ Enforce versioning
  versioning {
    enabled = true
  }

  # ✅ Enforce default encryption
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"   # Better than AES256
        kms_master_key_id = "alias/aws/s3" # Default AWS-managed KMS key
      }
    }
  }

  # ✅ Enforce lifecycle management
  lifecycle_rule {
    id      = "version-management"
    enabled = true

    # Transition old versions to infrequent access after 30 days
    noncurrent_version_transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    # Delete non-current versions after 90 days
    noncurrent_version_expiration {
      days = 90
    }

    # Expire current objects after 365 days
    expiration {
      days = 365
    }
  }

  # ✅ Block all public access
  public_access_block_configuration {
    block_public_acls       = true
    ignore_public_acls      = true
    block_public_policy     = true
    restrict_public_buckets = true
  }
}
💡 Variables (vars.tf)
variable "region" {
  description = "AWS region where the S3 bucket will be created"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Unique name for the S3 bucket"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the S3 bucket"
  type        = map(string)
  default = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
