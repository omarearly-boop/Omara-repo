# --- Outputs ---

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.wikijs.dns_name
}

output "rds_endpoint" {
  description = "The endpoint for the RDS cluster"
  value       = aws_rds_cluster.wikijs.endpoint
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket for Wiki.js storage"
  value       = aws_s3_bucket.storage.id
}
