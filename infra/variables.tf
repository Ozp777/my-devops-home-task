variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile name"
  type        = string
  default     = "default"
}

variable "vpc_id" {
  description = "VPC ID to deploy into"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID for EC2 instances"
  type        = string
}

variable "key_name" {
  description = "Existing EC2 key pair name for SSH"
  type        = string
}

variable "jenkins_instance_type" {
  description = "Instance type for Jenkins EC2"
  type        = string
  default     = "t3.small"
}

variable "app_instance_type" {
  description = "Instance type for App EC2"
  type        = string
  default     = "t3.small"
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH into EC2 instances"
  type        = string
  default     = "0.0.0.0/0"
}

variable "allowed_jenkins_ui_cidr" {
  description = "CIDR allowed to access Jenkins UI"
  type        = string
  default     = "0.0.0.0/0"
}

variable "allowed_app_http_cidr" {
  description = "CIDR allowed to access App HTTP endpoint"
  type        = string
  default     = "0.0.0.0/0"
}

variable "artifacts_bucket_name" {
  description = "S3 bucket name for artifacts (optional). If empty, bucket will not be created."
  type        = string
  default     = ""
}

