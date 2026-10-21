# AWS 3-Tier Highly-Available Web Application (Terraform)

> Production-grade, modular, multi-AZ 3-tier architecture on AWS — remote state, dev/prod environments, CI with security scanning, and least-privilege security throughout.
> **Author:** Muhammad Ahmad · **IaC:** Terraform (modular) · **Cloud:** AWS

![Terraform CI](https://github.com/AhmadMughal-DS/aws-3tier-ha-webapp-terraform/actions/workflows/terraform.yml/badge.svg)
![Terraform](https://img.shields.io/badge/Terraform-1.6%2B-7B42BC?logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-VPC%20%7C%20ALB%20%7C%20ASG%20%7C%20RDS-FF9900?logo=amazonaws&logoColor=white)
![Security](https://img.shields.io/badge/scanned-tfsec%20%7C%20checkov-success)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 🏗️ Architecture

> 🎨 **Interactive diagram (industry-standard icons):** [open in Lucid — page 1](https://lucid.app/lucidchart/3da75ce3-ea66-4296-81b3-00d20a60435b/edit)

```mermaid
flowchart TB
    User([🌐 Internet User])
    subgraph VPC["AWS VPC — multi-AZ"]
        IGW[Internet Gateway]
        subgraph Public["Public Subnets · 2 AZs"]
            ALB[Application LB<br/>+ access logs]
            NAT1[NAT GW AZ-a]
            NAT2[NAT GW AZ-b]
        end
        subgraph App["Private App Subnets · 2 AZs"]
            EC2A[EC2 Web · AZ-a]
            EC2B[EC2 Web · AZ-b]
        end
        subgraph Data["Private DB Subnets · 2 AZs"]
            RDS[(RDS MySQL<br/>Multi-AZ)]
            SM[Secrets Manager]
        end
    end
    User -->|HTTP/HTTPS| ALB
    ALB --> EC2A
    ALB --> EC2B
    EC2A -->|:3306 TLS| RDS
    EC2B -->|:3306 TLS| RDS
    RDS -.credentials.-> SM
    EC2A -.egress.-> NAT1
    EC2B -.egress.-> NAT2
    NAT1 --> IGW
    NAT2 --> IGW
```

## 📦 Module layout

```
terraform/
├── backend.tf                # remote S3 state + DynamoDB lock (bootstrap notes)
├── main.tf                   # composes the modules
├── variables.tf              # typed, validated inputs
├── environments/
│   ├── dev.tfvars
│   └── prod.tfvars
└── modules/
    ├── network/              # VPC, 2×(public/app/db) subnets, 2 NAT GW (HA), flow logs
    ├── security/             # ALB → Web → DB security groups (least privilege)
    ├── compute/              # ALB (access logs, HTTPS-ready), launch template, ASG, autoscaling
    └── database/             # RDS Multi-AZ, Secrets Manager, enhanced monitoring, alarms
```

## ✨ Production features

- **High availability** — resources span 2 AZs, with **one NAT gateway per AZ**.
- **Secrets** — the DB password is generated and stored in **AWS Secrets Manager** (never in code/state as plaintext input).
- **Encryption** — encrypted EBS and RDS storage; **TLS enforced** on RDS (`require_secure_transport`).
- **Observability** — VPC **flow logs**, RDS **enhanced monitoring** + **Performance Insights**, CloudWatch **alarms**.
- **Hardening** — IMDSv2 required, ALB **access logs** to S3, `drop_invalid_header_fields`, prod **deletion protection**.
- **CI** — GitHub Actions runs `fmt`, `validate`, **TFLint**, **tfsec**, and **Checkov** on every PR.

## 🚀 Deploy

```bash
cd terraform
terraform init
terraform plan  -var-file=environments/dev.tfvars
terraform apply -var-file=environments/dev.tfvars     # or prod.tfvars
```

> Remote state: bootstrap an S3 bucket + DynamoDB lock table, then uncomment `backend.tf` and run `terraform init -migrate-state`.

## 🧹 Clean up

```bash
terraform destroy -var-file=environments/dev.tfvars
```

## 💰 Cost note

ALB, NAT gateways (×2), and RDS Multi-AZ bill hourly and are **not free-tier**. Use `dev.tfvars` (single-AZ DB) for cheap demos and `destroy` when done.

---

*Built and maintained by **Muhammad Ahmad**.*
