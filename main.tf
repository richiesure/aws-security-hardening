provider "aws" {
  region = "eu-west-2"
}

data "aws_caller_identity" "current" {}

# S3 bucket for CloudTrail logs
resource "aws_s3_bucket" "cloudtrail" {
  bucket        = "security-audit-logs-${data.aws_caller_identity.current.account_id}"
  force_destroy = true

  tags = {
    Name    = "CloudTrail-Audit-Logs"
    Project = "Security-Hardening"
  }
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AWSCloudTrailAclCheck"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = aws_s3_bucket.cloudtrail.arn
      },
      {
        Sid       = "AWSCloudTrailWrite"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.cloudtrail.arn}/*"
        Condition = {
          StringEquals = { "s3:x-amz-acl" = "bucket-owner-full-control" }
        }
      }
    ]
  })
}

# CloudTrail for audit logging
resource "aws_cloudtrail" "main" {
  name                          = "security-audit-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true

  depends_on = [aws_s3_bucket_policy.cloudtrail]

  tags = {
    Name    = "Security-Audit-Trail"
    Project = "Security-Hardening"
  }
}

# GuardDuty for threat detection
resource "aws_guardduty_detector" "main" {
  enable = true

  tags = {
    Name    = "Threat-Detection"
    Project = "Security-Hardening"
  }
}

# Secrets Manager for secure credential storage
resource "aws_secretsmanager_secret" "app_credentials" {
  name                    = "app-database-credentials"
  description             = "Secure storage for application secrets"
  recovery_window_in_days = 7

  tags = {
    Name    = "App-Credentials"
    Project = "Security-Hardening"
  }
}

resource "aws_secretsmanager_secret_version" "app_credentials" {
  secret_id = aws_secretsmanager_secret.app_credentials.id
  secret_string = jsonencode({
    db_host     = "database.example.com"
    db_username = "app_user"
    db_password = "REPLACE_WITH_REAL_PASSWORD"
    api_key     = "REPLACE_WITH_REAL_KEY"
  })
}

# IAM password policy
resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 14
  require_lowercase_characters   = true
  require_uppercase_characters   = true
  require_numbers                = true
  require_symbols                = true
  allow_users_to_change_password = true
  max_password_age               = 90
  password_reuse_prevention      = 12
}

# SNS topic for security alerts
resource "aws_sns_topic" "security_alerts" {
  name = "security-alerts-topic"

  tags = {
    Name    = "Security-Alerts"
    Project = "Security-Hardening"
  }
}

resource "aws_sns_topic_subscription" "security_email" {
  topic_arn = aws_sns_topic.security_alerts.arn
  protocol  = "email"
  endpoint  = "richieprograms@gmail.com"
}

# CloudWatch alarm for unauthorized API calls
resource "aws_cloudwatch_metric_alarm" "unauthorized_api" {
  alarm_name          = "unauthorized-api-calls"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "UnauthorizedAttemptCount"
  namespace           = "CloudTrailMetrics"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Alert when multiple unauthorized API calls detected"
  alarm_actions       = [aws_sns_topic.security_alerts.arn]
  treat_missing_data  = "notBreaching"

  tags = {
    Name    = "Unauthorized-API-Alarm"
    Project = "Security-Hardening"
  }
}
