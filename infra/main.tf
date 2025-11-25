terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# ---------------------------------------------------
# AMI – Ubuntu 22.04 LTS
# ---------------------------------------------------
data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ---------------------------------------------------
# Security Group – Jenkins
# ---------------------------------------------------
resource "aws_security_group" "jenkins_sg" {
  name        = "devops-home-jenkins-sg"
  description = "Security group for Jenkins EC2"
  vpc_id      = var.vpc_id

  # SSH – רק מה-IP שלך בבית
  ingress {
    description = "SSH from home IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  # Jenkins UI – פורט 8080, רק מה-IP שלך
  ingress {
    description = "Jenkins UI from home IP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.allowed_jenkins_ui_cidr]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-home-jenkins-sg"
  }
}

# ---------------------------------------------------
# Security Group – App
# ---------------------------------------------------
resource "aws_security_group" "app_sg" {
  name        = "devops-home-app-sg"
  description = "Security group for App EC2"
  vpc_id      = var.vpc_id

  # SSH – מה-IP שלך (לניהול ידני)
  ingress {
    description = "SSH from home IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  # HTTP – מהעולם
  ingress {
    description = "HTTP from world"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.allowed_app_http_cidr]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-home-app-sg"
  }
}

# SSH מה-Jenkins SG ל-App SG (בשביל ה-Deploy מה-Pipeline)
resource "aws_security_group_rule" "app_ssh_from_jenkins" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.app_sg.id
  source_security_group_id = aws_security_group.jenkins_sg.id
  description              = "Allow SSH from Jenkins SG for deployments"
}

# ---------------------------------------------------
# IAM Role + Instance Profile ל-Jenkins (גישה ל-S3 וכו')
# ---------------------------------------------------
resource "aws_iam_role" "jenkins_role" {
  name = "devops-home-jenkins-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "devops-home-jenkins-instance-profile"
  role = aws_iam_role.jenkins_role.name
}

# מדיניות בסיסית ל-S3 (רק אם יש bucket)
resource "aws_iam_policy" "jenkins_s3_policy" {
  count = var.artifacts_bucket_name == "" ? 0 : 1

  name = "devops-home-jenkins-s3-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.artifacts_bucket_name}",
          "arn:aws:s3:::${var.artifacts_bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "jenkins_s3_attach" {
  count      = var.artifacts_bucket_name == "" ? 0 : 1
  role       = aws_iam_role.jenkins_role.name
  policy_arn = aws_iam_policy.jenkins_s3_policy[0].arn
}

# ---------------------------------------------------
# S3 Bucket לארטיפקטים (אופציונלי, לפי terraform.tfvars)
# ---------------------------------------------------
resource "aws_s3_bucket" "artifacts" {
  count  = var.artifacts_bucket_name == "" ? 0 : 1
  bucket = var.artifacts_bucket_name

  tags = {
    Name = "devops-home-artifacts"
  }
}

# ---------------------------------------------------
# Jenkins EC2
# ---------------------------------------------------
resource "aws_instance" "jenkins" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.jenkins_instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  iam_instance_profile = aws_iam_instance_profile.jenkins_profile.name

  user_data = file("${path.module}/user_data_jenkins.sh")

  tags = {
    Name = "devops-home-jenkins"
    Role = "jenkins"
  }
}

# ---------------------------------------------------
# App EC2
# ---------------------------------------------------
resource "aws_instance" "app" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.app_instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  user_data = file("${path.module}/user_data_app.sh")

  tags = {
    Name = "devops-home-app"
    Role = "app"
  }
}

