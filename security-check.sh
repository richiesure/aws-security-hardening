#!/bin/bash
echo "=========================================="
echo "SECURITY AUDIT REPORT"
echo "=========================================="
echo ""

echo "1. CloudTrail Status:"
aws cloudtrail get-trail-status --name security-audit-trail --region eu-west-2 --query 'IsLogging'
echo ""

echo "2. GuardDuty Findings (threats detected):"
DETECTOR_ID=$(aws guardduty list-detectors --region eu-west-2 --query 'DetectorIds[0]' --output text)
aws guardduty list-findings --detector-id $DETECTOR_ID --region eu-west-2 --query 'FindingIds | length(@)'
echo "findings found"
echo ""

echo "3. Password Policy:"
aws iam get-account-password-policy --query 'PasswordPolicy.MinimumPasswordLength' 2>/dev/null || echo "Not configured"
echo ""

echo "4. Secrets in Secrets Manager:"
aws secretsmanager list-secrets --region eu-west-2 --query 'SecretList[*].Name' --output table
echo ""

echo "5. Open Security Groups (0.0.0.0/0):"
aws ec2 describe-security-groups --region eu-west-2 \
  --query 'SecurityGroups[?IpPermissions[?IpRanges[?CidrIp==`0.0.0.0/0`]]].GroupName' \
  --output table
echo ""

echo "=========================================="
echo "AUDIT COMPLETE"
echo "=========================================="
