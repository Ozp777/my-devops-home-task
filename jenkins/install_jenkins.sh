#!/usr/bin/env bash
set -e

# עדכונים
sudo apt-get update

# ג'אווה
sudo apt-get install -y fontconfig openjdk-11-jre

# ריפו של Jenkins
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update
sudo apt-get install -y jenkins docker.io git

# להוסיף את jenkins לקבוצת docker
sudo usermod -aG docker jenkins
sudo systemctl enable docker
sudo systemctl restart docker
sudo systemctl restart jenkins

