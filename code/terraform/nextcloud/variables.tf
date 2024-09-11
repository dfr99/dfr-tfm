variable "name_prefix" {
  type        = string
  description = "value to be prefixed to all resources"
  default     = "nextcloud"
  sensitive   = false
}

variable "rds_password" {
  type        = string
  description = "password for the RDS instance"
  sensitive   = true
}

variable "s3_sns_topic_email" {
  type        = string
  description = "SNS topic ARN for email notifications related to S3"
  sensitive   = true
}

variable "lambda_sns_topic_email" {
  type        = string
  description = "SNS topic ARN for email notifications related to Lambda"
  sensitive   = true
}

variable "sfm_sns_topic_email" {
  type        = string
  description = "SNS topic ARN for SMS notifications related to Step Functions"
  sensitive   = true
}

# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/enable-access-logging.html
variable "alb_account_id" {
  type        = string
  description = "AWS account ID for the ALB"
  sensitive   = false
  default     = "054676820928"
}
