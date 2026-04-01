# 🚀 Terraform AWS Infrastructure – Revision Notes

## 📌 Project Overview

This project provisions AWS infrastructure using Terraform, including networking, compute, and a web server setup.

It creates a complete flow:
Local Machine → Terraform → AWS Infrastructure → EC2 → Nginx Web Server

---

# 🌐 Networking Components

## 🔹 VPC (Virtual Private Cloud)

- Creates an isolated network in AWS
- CIDR Block: `10.0.0.0/16`
- Acts as the foundation for all resources

👉 Interview Tip:
VPC is like your private data center inside AWS

---

## 🔹 Subnet (Public)

- CIDR Block: `10.0.1.0/24`
- `map_public_ip_on_launch = true` assigns public IP automatically

👉 Makes it a **public subnet**

---

## 🔹 Internet Gateway (IGW)

- Allows communication between VPC and the internet
- Attached to the VPC

---

## 🔹 Route Table

- Controls traffic routing inside the VPC
- Rule:
  `0.0.0.0/0 → Internet Gateway`

👉 Meaning:
All outbound traffic goes to the internet

---

## 🔹 Route Table Association

- Links subnet with route table
- Required for routing to work

---

# 🔥 Security

## 🔹 Security Group

- Acts as a firewall at instance level
- Allows:
  - SSH (Port 22)
  - HTTP (Port 80)
- Stateful → return traffic automatically allowed

---

# 💻 Compute

## 🔹 EC2 (Elastic Compute Cloud)

- Virtual server in AWS
- Runs inside public subnet
- Assigned a public IP

---

## 🔹 AMI (Amazon Machine Image)

- Template used to launch EC2
- Fetched dynamically using Terraform data source

👉 Avoids hardcoding AMI IDs

---

# ⚙️ User Data (Bootstrap Script)

## 🔹 Purpose

Automates configuration of EC2 during launch

## 🔹 Actions Performed

- Installs Nginx
- Starts and enables Nginx service
- Fetches metadata using IMDSv2:
  - Instance ID
  - Region
  - Public IP

## 🔹 Output

- Creates a dynamic HTML page
- Displays infrastructure details

---

# 📦 Terraform Concepts

## 🔹 Provider

- Connects Terraform to AWS

---

## 🔹 Resource

- Defines infrastructure components
- Example: VPC, EC2, Subnet

---

## 🔹 Data Source

- Fetches existing AWS data
- Example: Latest Amazon Linux AMI

---

## 🔹 Variables

- Makes configuration reusable and flexible

---

## 🔹 State File

- Tracks current infrastructure
- Helps Terraform understand what is already created

---

# 🔄 Execution Flow

1. Terraform initializes AWS provider
2. VPC is created
3. Subnet is created inside VPC
4. Internet Gateway is attached
5. Route Table is configured
6. Subnet is associated with Route Table
7. Security Group is created
8. Latest AMI is fetched
9. EC2 instance is launched
10. User data installs and starts Nginx

---

# 🧠 Deep-Dive Interview Questions (Think Like an Engineer)

## 🌐 Networking

### ❓ If your EC2 instance has a public IP but still cannot access the internet, what could be wrong?

👉 Think:

- Route table missing IGW route?
- IGW not attached?
- Security group outbound rules?

---

### ❓ Why is just attaching an Internet Gateway not enough to make a subnet public?

👉 Think:

- Route table association is required
- Traffic path must be explicitly defined

---

### ❓ What would change if this subnet was private instead of public?

👉 Think:

- No public IP
- Need NAT Gateway for internet access
- Different route table

---

### ❓ How would you design this architecture for high availability across AZs?

👉 Think:

- Multiple subnets
- Multi-AZ deployment
- Load balancer

---

## 🔥 Security

### ❓ What is the real difference between Security Group and NACL in this setup?

👉 Think:

- Stateful vs stateless
- Layer of application (instance vs subnet)

---

### ❓ What happens if you remove the egress rule from the security group?

👉 Think:

- Can instance install Nginx?
- Can it access internet?

---

### ❓ Why is allowing SSH from `0.0.0.0/0` risky, and how would you fix it?

👉 Think:

- Restrict to your IP
- Use bastion host

---

## 💻 EC2 & User Data

### ❓ What happens if the user_data script fails midway?

👉 Think:

- EC2 still runs
- App might be broken
- Need logs (/var/log/cloud-init.log)

---

### ❓ Why use IMDSv2 instead of IMDSv1?

👉 Think:

- Security improvements
- Token-based authentication

---

### ❓ If you stop and start the EC2 instance, will user_data run again?

👉 Answer:

- No (only runs on first launch)

---

## 📦 Terraform

### ❓ How does Terraform know in which order to create resources?

👉 Think:

- Dependency graph
- Implicit references

---

### ❓ What happens if you manually delete the EC2 instance from AWS?

👉 Think:

- State mismatch
- Terraform will recreate on next apply

---

### ❓ Why is remote state important in a team environment?

👉 Think:

- Collaboration
- Avoid conflicts
- Centralized state

---

### ❓ What problem does state locking solve?

👉 Think:

- Prevent concurrent modifications
- Avoid corruption

---

### ❓ What is the difference between resource and data source?

👉 Think:

- Resource → creates
- Data source → fetches

---

## 🚀 Architecture Thinking

### ❓ What are the limitations of this current architecture?

👉 Think:

- Single EC2 (single point of failure)
- No auto scaling
- No load balancing

---

### ❓ How would you make this production-ready?

👉 Think:

- ALB
- Auto Scaling Group
- Multi-AZ
- Monitoring

---

### ❓ If traffic suddenly increases 10x, what will break first?

👉 Think:

- Single EC2 capacity
- No scaling

---

### ❓ How would you separate dev and prod environments in Terraform?

👉 Think:

- Workspaces
- Separate state
- Variable files

---

# 🎯 Interview Explanation (Use This)

I created AWS infrastructure using Terraform where I provisioned a custom VPC, public subnet, internet gateway, and route table. I deployed an EC2 instance with a security group allowing SSH and HTTP access. I used a data source to fetch the latest Amazon Linux AMI and user data to install and configure Nginx. The instance dynamically displays metadata like instance ID and IP on a custom web page.

---

# ⚠️ Improvements to Implement

- Fix incorrect IPv6 rule in security group
- Add key pair for SSH access
- Use `vpc_security_group_ids` instead of `security_groups`
- Convert code into reusable modules
- Add Load Balancer (ALB)
- Implement Auto Scaling Group
- Add CI/CD pipeline

---

# 🧠 Quick Revision Checklist

- [ ] VPC vs Subnet difference
- [ ] Public vs Private subnet
- [ ] Security Group vs NACL
- [ ] What is user_data?
- [ ] What is AMI data source?
- [ ] How Terraform manages state?
- [ ] Execution flow of Terraform

---

# 💡 Key Takeaway

This project demonstrates how to use Terraform to automate AWS infrastructure and deploy a working web server using Infrastructure as Code (IaC).
