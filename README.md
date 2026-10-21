# AWS 3-Tier Highly-Available Web Application (Terraform)

> Production-style, multi-AZ 3-tier architecture on AWS, fully provisioned with Terraform.
> **Author:** Muhammad Ahmad · **IaC:** Terraform · **Cloud:** AWS

![Terraform](https://img.shields.io/badge/Terraform-1.5%2B-7B42BC?logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-VPC%20%7C%20ALB%20%7C%20ASG%20%7C%20RDS-FF9900?logo=amazonaws&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 📌 Overview

This project deploys a classic, resilient **3-tier web application** across **two Availability Zones** for high availability:

- **Web / Presentation tier** — an internet-facing **Application Load Balancer** distributing traffic to an **Auto Scaling Group** of EC2 instances running nginx.
- **Application tier** — EC2 instances live in **private subnets** (no public IPs); outbound internet access goes through a **NAT Gateway**.
- **Data tier** — an **Amazon RDS for MySQL** instance with **Multi-AZ** failover, isolated in dedicated private DB subnets.

Security is layered so each tier only accepts traffic from the tier in front of it.

## 🏗️ Architecture

> 🎨 **Interactive diagram (industry-standard icons):** [open in Lucid — page 1](https://lucid.app/lucidchart/3da75ce3-ea66-4296-81b3-00d20a60435b/edit)

```mermaid
flowchart TB
    User([🌐 Internet User])

    subgraph VPC["AWS VPC — 10.0.0.0/16"]
        IGW[Internet Gateway]

        subgraph Public["Public Subnets · 2 AZs"]
            ALB[Application<br/>Load Balancer]
            NAT[NAT Gateway]
        end

        subgraph App["Private App Subnets · 2 AZs"]
            EC2A[EC2 Web · AZ-a]
            EC2B[EC2 Web · AZ-b]
        end

        subgraph Data["Private DB Subnets · 2 AZs"]
            RDS[(RDS MySQL<br/>Multi-AZ)]
        end
    end

    User -->|HTTP :80| ALB
    ALB --> EC2A
    ALB --> EC2B
    EC2A -->|:3306| RDS
    EC2B -->|:3306| RDS
    EC2A -.outbound.-> NAT
    EC2B -.outbound.-> NAT
    NAT --> IGW
```

## 🧱 What Terraform provisions

| Layer | Resources |
|-------|-----------|
| Networking | VPC, Internet Gateway, 2× public / 2× app / 2× DB subnets, NAT Gateway, route tables |
| Security | 3 security groups (ALB → Web → DB) with least-privilege rules |
| Load balancing | Application Load Balancer, target group, HTTP listener, health checks |
| Compute | Launch Template (Amazon Linux 2023 + IMDSv2), Auto Scaling Group, CPU target-tracking policy |
| Database | RDS MySQL 8.0, Multi-AZ, encrypted storage, 7-day backups, private DB subnet group |

## 🚀 Deploy

**Prerequisites:** Terraform ≥ 1.5, AWS credentials configured (`aws configure`).

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars   # edit values as needed

# Provide the DB password securely (do not commit it)
export TF_VAR_db_password='YourStrongPassword123!'

terraform init
terraform plan
terraform apply
```

When the apply finishes, open the `application_url` output in a browser — refresh a few times and you'll see requests served by different instances / AZs.

```bash
terraform output application_url
```

## 🧹 Clean up

```bash
terraform destroy
```

## 💰 Cost note

Uses small/`t3.micro`-class resources, but **ALB, NAT Gateway, and RDS Multi-AZ are not free-tier** and bill hourly. Run `terraform destroy` when you're done to avoid charges.

## 🔐 Production hardening (next steps)

- Store the DB password in **AWS Secrets Manager** instead of a variable.
- Add an **HTTPS listener** with an ACM certificate and redirect HTTP → HTTPS.
- Restrict ALB ingress to a WAF / known CIDRs.
- Enable **RDS enhanced monitoring** and deletion protection.

---

*Built and maintained by **Muhammad Ahmad**.*
