# Terraform AWS Infrastructure Lab 🚀

This project provisions AWS infrastructure using Terraform with a remote S3 backend and native state locking.

---

## 🏗 What This Project Does

- Creates a Custom VPC (10.0.0.0/16)
- Creates a Public Subnet (10.0.1.0/24)
- Attaches an Internet Gateway
- Configures Route Tables
- Creates a Security Group (HTTP + SSH)
- Launches an EC2 instance (Amazon Linux)
- Installs and starts Nginx automatically using user_data
- Uses S3 as a remote backend with native lockfile support

---

## 🔐 Remote Backend

Terraform state is stored in Amazon S3.

This project uses:

- S3 remote state
- Server-side encryption
- Native state locking using `use_lockfile = true`

Note:
Earlier setups commonly used DynamoDB for locking.
This project uses Terraform's updated S3 native locking capability.

---

## 🔄 Infrastructure Workflow

1. Terraform initialized with S3 backend
2. State stored securely in S3
3. VPC and networking components created
4. Security group configured
5. EC2 instance launched
6. Nginx installed automatically
7. Custom landing page deployed

---

## 📂 Files in This Project

- backend.tf
- main.tf
- variables.tf
- outputs.tf
- versions.tf
- .gitignore
- README.md

---

## 🚀 How To Run

Initialize Terraform:

terraform init

Validate:

terraform validate

Plan:

terraform plan

Apply:

terraform apply

Destroy (important to avoid charges):

terraform destroy

---

## 🧠 Key Learnings

- Terraform remote backend configuration
- S3 native state locking
- AWS VPC networking fundamentals
- Automated EC2 provisioning using user_data
- Infrastructure as Code best practices

---
