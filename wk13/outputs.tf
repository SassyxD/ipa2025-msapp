output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID"
}

output "public_subnet_ids" {
  value       = values(aws_subnet.public)[*].id
  description = "Public subnet IDs"
}

output "web_public_dns" {
  value       = aws_instance.web[*].public_dns
  description = "EC2 public DNS list"
}

output "s3_bucket_name" {
  value       = aws_s3_bucket.site_bucket.bucket
  description = "S3 bucket created for content"
}
