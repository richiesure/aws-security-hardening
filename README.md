# AWS Security Hardening

Enterprise-grade security implementation for AWS infrastructure including audit logging, threat detection, secrets management, and compliance enforcement.

## What Was Implemented

### 1. CloudTrail (Audit Logging)
- Records all API calls across AWS account
- Multi-region coverage for complete visibility
- Logs stored in encrypted S3 bucket
- Essential for compliance and forensics

### 2. GuardDuty (Threat Detection)
- Machine learning-based threat detection
- Monitors for malicious activity
- Detects compromised instances, reconnaissance, and data exfiltration
- Automatic alerts on findings

### 3. Secrets Manager
- Secure credential storage (no hardcoded passwords)
- Automatic rotation capability
- Encrypted at rest with KMS
- Access controlled via IAM policies

### 4. IAM Password Policy
- Minimum 14 characters
- Requires uppercase, lowercase, numbers, symbols
- 90-day password expiration
- Prevents reuse of last 12 passwords

### 5. Security Alerting
- SNS topic for security notifications
- CloudWatch alarms for suspicious activity
- Email alerts for unauthorized API calls

## Architecture
```
┌─────────────────────────────────────────────────────────┐
│                  AWS Security Layer                      │
│                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │
│  │  CloudTrail  │  │  GuardDuty   │  │   Secrets    │   │
│  │  (Auditing)  │  │  (Threats)   │  │   Manager    │   │
│  └──────┬───────┘  └──────┬───────┘  └──────────────┘   │
│         │                 │                              │
│         ▼                 ▼                              │
│  ┌──────────────┐  ┌──────────────┐                     │
│  │  S3 Bucket   │  │  SNS Topic   │──▶ Email Alerts    │
│  │  (Log Store) │  │  (Alerts)    │                     │
│  └──────────────┘  └──────────────┘                     │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │           IAM Password Policy                     │   │
│  │  14 chars │ Complex │ 90-day expiry │ No reuse   │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

## Files Structure
```
aws-security-hardening/
├── main.tf              # Security infrastructure
├── outputs.tf           # Output values
├── security-check.sh    # Audit script
└── README.md
```

## Security Audit Results

| Check | Status | Details |
|-------|--------|---------|
| CloudTrail Logging | ✅ Active | Multi-region enabled |
| GuardDuty | ✅ Active | 0 threats detected |
| Password Policy | ✅ Enforced | 14 char minimum |
| Secrets Manager | ✅ Configured | 1 secret stored |
| Open Security Groups | ⚠️ Found 4 | Review needed |

## Usage

### Run Security Audit
```bash
./security-check.sh
```

### Retrieve Secret (Application Use)
```bash
aws secretsmanager get-secret-value \
  --secret-id app-database-credentials \
  --region eu-west-2 \
  --query 'SecretString' --output text
```

### Check GuardDuty Findings
```bash
DETECTOR_ID=$(aws guardduty list-detectors --region eu-west-2 --query 'DetectorIds[0]' --output text)
aws guardduty list-findings --detector-id $DETECTOR_ID --region eu-west-2
```

## Cost

| Service | Monthly Cost |
|---------|-------------|
| CloudTrail | ~$2 (per 100k events) |
| GuardDuty | ~$4 (per million events) |
| Secrets Manager | $0.40 per secret |
| S3 Storage | ~$0.50 |
| **Total** | **~$7/month** |

## Compliance Frameworks Supported

- SOC 2 (Audit logging, access controls)
- HIPAA (Encryption, audit trails)
- PCI-DSS (Security monitoring)
- GDPR (Data protection)
