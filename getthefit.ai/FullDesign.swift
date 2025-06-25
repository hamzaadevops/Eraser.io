title AWS Production Architecture
GitLab CI [icon: gitlab]
VPC [icon: aws-vpc, color: blue, label: "VPC"] {
  KMS Key [icon: aws-kms, label: "KMS Key"]
  IAM Roles [icon: aws-iam, label: "IAM Roles"]
  VPC Flow Logs [icon: aws-vpc-flow-logs, label: "VPC Flow Logs"]

    ALB [icon: aws-alb, label: "ALB (HTTPS)"]
    WAF [icon: aws-waf, label: "WAF"]
    ALB SG [icon: aws-security-group, label: "ALB SG"]
    ALB Logs S3 [icon: aws-s3, label: "ALB Logs S3"]

  Compute [icon: aws-ec2-auto-scaling, label: "Compute"] {
    ASG [icon: aws-ec2-auto-scaling, label: "ASG"] {
      EC2 OnDemand [icon: aws-ec2, label: "EC2 On-Demand"]
      EC2 Spot [icon: aws-spot-fleet, label: "EC2 Spot"]
      EC2 Reserved [icon: aws-reserved-instance-reporting, label: "EC2 Reserved"]
    }
    EC2 SG [icon: aws-security-group, label: "EC2 SG"]
    EBS [icon: aws-ebs, label: "EBS Encrypted"]
    AMI Backups [icon: aws-s3, label: "AMI Backups"]
  }

  Storage [icon: aws-s3, label: "Storage"] {
    ML Model S3 [icon: aws-s3, label: "ML Model S3 (Versioned)"]
    Artifact S3 [icon: aws-s3, label: "Artifact S3"]
    Log S3 [icon: aws-s3, label: "Log S3"]
  }

//   Monitoring [icon: aws-cloudwatch, label: "Monitoring"] 
  CodeDeploy [icon: aws-codedeploy, label: "CodeDeploy (Blue/Green)"]
  OpenSearch [icon: aws-opensearch-service, label: "OpenSearch Cluster"] 
  OpenSearch VPC Endpoint [icon: aws-vpc-endpoint]
}


// Connections
OpenSearch VPC Endpoint < ASG
// : HTTPS, VPC-only
OpenSearch VPC Endpoint > OpenSearch 
// : HTTPS & VPC Only  
OpenSearch --> Log S3
// : Service logs

VPC Flow Logs > Log S3
// : "Network audit logs"

// Security Groups, IAM, KMS (visual only, not direct flows)
Users [icon: users]

Users > WAF > ALB
ALB > ALB SG
// : "Inbound 443 only"
ALB SG > ASG
// : "Public Traffic"
ALB --> ALB Logs S3: "Access logs"
ASG > EC2 SG: "Allow from ALB only"
ASG > ML Model S3
// : Read-only, IAM, KMS
ASG --> AMI Backups
// : AMI backup

Storage > KMS Key
// : "Encryption"
AMI Backups > KMS Key
// : "Encryption"

ASG > IAM Roles
CodeDeploy > IAM Roles
OpenSearch > IAM Roles

// CI/CD: GitLab CI to S3 (artifacts), then CodeDeploy to EC2 (Blue/Green)
Artifact S3 < GitLab CI 
// : "Upload build artifacts"
Artifact S3 > CodeDeploy
// : "Trigger deployment"
CodeDeploy > ASG
//  : "Blue/Green deployment"

