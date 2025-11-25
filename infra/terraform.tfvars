aws_region       = "us-east-1"
aws_profile      = "default"

vpc_id           = "vpc-02d31d79a74957684"
public_subnet_id = "subnet-0c76b208780765593"

key_name         = "devops-home-key-2"

jenkins_instance_type = "t3.small"
app_instance_type     = "t3.small"

# 💡 נועל SSH + גישת Jenkins רק ל-IP שלך
allowed_ssh_cidr        = "77.125.228.126/32"
allowed_jenkins_ui_cidr = "77.125.228.126/32"

# 🟢 לאפליקציה עדיף להשאיר פתוח כדי לבדוק מהסמארטפון/חברים
allowed_app_http_cidr   = "0.0.0.0/0"

# יש לנו S3 שהצלחת ליצור
artifacts_bucket_name   = ""

