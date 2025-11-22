output "cloudtrail_name" {
  description = "CloudTrail name for audit logging"
  value       = aws_cloudtrail.main.name
}

output "cloudtrail_s3_bucket" {
  description = "S3 bucket storing CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail.id
}

output "guardduty_detector_id" {
  description = "GuardDuty detector ID"
  value       = aws_guardduty_detector.main.id
}

output "secrets_manager_arn" {
  description = "Secrets Manager secret ARN"
  value       = aws_secretsmanager_secret.app_credentials.arn
}

output "security_alerts_topic" {
  description = "SNS topic for security alerts"
  value       = aws_sns_topic.security_alerts.arn
}
