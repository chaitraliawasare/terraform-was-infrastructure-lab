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
              dnf install nginx -y
              systemctl start nginx
              systemctl enable nginx

              # Get IMDSv2 token
              TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
              -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

              # Fetch instance metadata
              INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
              http://169.254.169.254/latest/meta-data/instance-id)

              REGION=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
              http://169.254.169.254/latest/meta-data/placement/region)

              PUBLIC_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
              http://169.254.169.254/latest/meta-data/public-ipv4)

              # Create custom HTML page
              cat <<EOT > /usr/share/nginx/html/index.html
              <!DOCTYPE html>
              <html>
              <head>
                  <meta charset="UTF-8">
                  <title>Terraform AWS Infrastructure</title>
                  <style>
                      body {
                          font-family: Arial, sans-serif;
                          background: linear-gradient(135deg, #0f172a, #1e293b);
                          color: #f1f5f9;
                          text-align: center;
                          padding: 40px;
                      }
                      h1 {
                          color: #38bdf8;
                          animation: glow 2s ease-in-out infinite alternate;
                      }
                      @keyframes glow {
                          from { text-shadow: 0 0 5px #38bdf8; }
                          to { text-shadow: 0 0 20px #38bdf8; }
                      }
                      .box {
                          background: #1e293b;
                          padding: 20px;
                          margin: 20px auto;
                          border-radius: 12px;
                          width: 70%;
                          box-shadow: 0 0 15px rgba(0,0,0,0.5);
                      }
                      a {
                          color: #38bdf8;
                          text-decoration: none;
                      }
                      img {
                          width: 80%;
                          border-radius: 10px;
                          margin-top: 20px;
                      }
                  </style>
              </head>
              <body>

                  <h1>🚀 Terraform AWS Infrastructure</h1>
                  <p>Provisioned using Infrastructure as Code</p>

                  <div class="box">
                      <h2>📊 Instance Metadata</h2>
                      <p><strong>Instance ID:</strong> $INSTANCE_ID</p>
                      <p><strong>Region:</strong> $REGION</p>
                      <p><strong>Public IP:</strong> $PUBLIC_IP</p>
                  </div>

                  <div class="box">
                      <h2>🏗 Infrastructure Components</h2>
                      <ul style="text-align:left;">
                          <li>Custom VPC (10.0.0.0/16)</li>
                          <li>Public Subnet</li>
                          <li>Internet Gateway</li>
                          <li>Route Table Association</li>
                          <li>Security Group</li>
                          <li>EC2 with Nginx</li>
                          <li>S3 Remote Backend with Lockfile</li>
                      </ul>
                  </div>

                  <div class="box">
                      <h2>🔗 Project Links</h2>
                      <p><a href="https://github.com/YOUR_GITHUB_USERNAME/terraform-aws-lab" target="_blank">GitHub Repository</a></p>
                      <p><a href="https://www.linkedin.com/in/YOUR_LINKEDIN" target="_blank">LinkedIn Profile</a></p>
                  </div>

                  <div class="box">
                      <h2>🖼 Architecture Diagram</h2>
                      <img src="https://d1.awsstatic.com/architecture-diagrams/ArchitectureDiagrams/web-application-architecture.8a4b16d7b9e5e8b7e03a8c6b0c4b4e0f.png" alt="Architecture Diagram">
                  </div>

                  <p>Built by Chaitrali 🚀</p>

              </body>
              </html>
              EOT
              EOF


  tags = {
    Name = "Terraform-Web-Server"
  }
}