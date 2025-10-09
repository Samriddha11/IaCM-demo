variable "region" {
  description = "AWS region"
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "tags" {
  description = "Tags for the bucket"
  type        = map(string)
  default     = {}
}
