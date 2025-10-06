resource "random_id" "suffix" {
  byte_length = 3
}

resource "aws_s3_bucket" "site_bucket" {
  bucket = "${local.name_prefix}-content-${random_id.suffix.hex}"
  force_destroy = true

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-content" })
}

resource "aws_s3_bucket_ownership_controls" "own" {
  bucket = aws_s3_bucket.site_bucket.id
  rule { object_ownership = "BucketOwnerPreferred" }
}

resource "aws_s3_bucket_public_access_block" "pab" {
  bucket                  = aws_s3_bucket.site_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "readme" {
  bucket  = aws_s3_bucket.site_bucket.id
  key     = "README.txt"
  content = "Hello from ${local.name_prefix} at ${timestamp()}"
  etag    = filemd5("${path.module}/versions.tf") # trick ให้ content เปลี่ยนตามไฟล์
  depends_on = [aws_s3_bucket_ownership_controls.own, aws_s3_bucket_public_access_block.pab]
}
