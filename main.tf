provider "aws" {
  region = var.region

}
#Create VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {

    Name = "terraform-vpc"
  }

}

#Create Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

#Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

#Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

#Route Table Association
resource "aws_route_table_association" "assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

#Security Group
resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    ipv6_cidr_blocks = ["409:4090:2004:200a:5cce:83b7:84ef:78bd/128"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}


#Launch EC2 Instance
resource "aws_instance" "web" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  security_groups             = [aws_security_group.sg.id]
  associate_public_ip_address = true

user_data = <<-EOF
#!/bin/bash

dnf install -y nginx
systemctl enable nginx
systemctl start nginx

TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
-H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
http://169.254.169.254/latest/meta-data/instance-id)

REGION=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
http://169.254.169.254/latest/meta-data/placement/region)

PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
http://169.254.169.254/latest/meta-data/public-ipv4)

tee /usr/share/nginx/html/index.html > /dev/null <<HTML
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Terraform AWS Infrastructure</title>

<style>
body {
  margin: 0;
  font-family: 'Segoe UI', sans-serif;
  background: linear-gradient(135deg, #0f172a, #1e293b);
  color: #f1f5f9;
  text-align: center;
  padding: 40px;
}

/* Glow animation */
@keyframes glow {
  from { text-shadow: 0 0 5px #38bdf8; }
  to { text-shadow: 0 0 20px #38bdf8, 0 0 30px #38bdf8; }
}

h1 {
  font-size: 42px;
  color: #38bdf8;
  animation: glow 2s ease-in-out infinite alternate;
}

/* Card styling */
.box {
  background: #1e293b;
  padding: 25px;
  margin: 25px auto;
  border-radius: 15px;
  width: 65%;
  box-shadow: 0 0 20px rgba(0,0,0,0.6);
  transition: transform 0.3s ease;
}

.box:hover {
  transform: scale(1.02);
}

/* Buttons */
.button {
  display: inline-block;
  padding: 12px 20px;
  margin: 10px;
  border-radius: 8px;
  text-decoration: none;
  font-weight: bold;
  background: #0ea5e9;
  color: white;
  box-shadow: 0 0 10px #0ea5e9;
  transition: 0.3s ease;
}

.button:hover {
  background: #38bdf8;
  box-shadow: 0 0 20px #38bdf8;
}

/* Badge glow */
.badge {
  display: inline-block;
  padding: 8px 14px;
  margin: 8px;
  border-radius: 20px;
  background: #334155;
  box-shadow: 0 0 10px #22d3ee;
  transition: 0.3s ease;
}

.badge:hover {
  box-shadow: 0 0 20px #22d3ee;
  transform: scale(1.1);
}
</style>
</head>

<body>

<h1>Terraform AWS Infrastructure 🚀</h1>
<p>Provisioned using Infrastructure as Code</p>

<div class="box">
<h2>Technology Stack</h2>
<div class="badge">Terraform</div>
<div class="badge">AWS</div>
<div class="badge">S3 Backend</div>
<div class="badge">EC2</div>
<div class="badge">Nginx</div>
</div>

<div class="box">
<h2>Infrastructure Workflow</h2>
<p>🖥 Local Machine → Terraform</p>
<p>☁ S3 Remote Backend (State + Lockfile)</p>
<p>🌐 Custom VPC & Networking</p>
<p>🚀 EC2 Instance Created</p>
<p>🌍 Nginx Web Server Running</p>
</div>

<div class="box">
<h2>Connect With Me</h2>
<a class="button" href="https://github.com/chaitraliawasare/terraform-was-infrastructure-lab" target="_blank">GitHub</a>
<a class="button" href="https://www.linkedin.com/in/chaitrali-awasare" target="_blank">LinkedIn</a>
</div>

<p style="margin-top:40px;">Built by Chaitrali 💻✨</p>

</body>
</html>
HTML

EOF



  tags = {
    Name = "Terraform-Web-Server"
  }
}