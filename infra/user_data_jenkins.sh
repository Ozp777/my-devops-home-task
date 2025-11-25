#!/usr/bin/env bash
set -eux

# ---- עדכוני מערכת ----
apt-get update -y

# ---- Java 17 (נדרש לגרסאות Jenkins החדשות) ----
apt-get install -y fontconfig openjdk-17-jre

# ---- הוספת ריפו Jenkins ----
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ \
  | tee /etc/apt/sources.list.d/jenkins.list > /dev/null

apt-get update -y

# ---- התקנת Jenkins ----
apt-get install -y jenkins

# ---- התקנת Docker + הכנת הרשאות ----
apt-get install -y docker.io

# יצירת קבוצת docker אם לא קיימת
if ! getent group docker >/dev/null; then
    groupadd docker
fi

# הוספת משתמשים לקבוצת docker
usermod -aG docker jenkins
usermod -aG docker ubuntu

# הפעלת Docker
systemctl enable docker
systemctl restart docker

# ---- הפעלת Jenkins ----
systemctl enable jenkins
systemctl restart jenkins

