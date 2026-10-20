#!/bin/bash
set -euo pipefail

# Install and start nginx on Amazon Linux 2023
dnf update -y
dnf install -y nginx

# Read instance metadata (IMDSv2)
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 300")
IID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/instance-id)
AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/placement/availability-zone)

cat > /usr/share/nginx/html/index.html <<HTML
<!doctype html>
<html>
  <head><title>3-Tier HA Web App</title></head>
  <body style="font-family:sans-serif;text-align:center;padding-top:60px">
    <h1>3-Tier Highly Available Web App</h1>
    <p>Provisioned with Terraform by <b>Muhammad Ahmad</b></p>
    <p>Served by instance <b>$IID</b> in Availability Zone <b>$AZ</b></p>
  </body>
</html>
HTML

systemctl enable nginx
systemctl start nginx
