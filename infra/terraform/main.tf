provider "aws" {
  region = "eu-north-1"
}

#
data "aws_secretsmanager_secret" "admin_key" {
  name = "weather-app-admin"
}

data "aws_secretsmanager_secret_version" "admin_key_version" {
  secret_id = data.aws_secretsmanager_secret.admin_key.id
}

data "aws_secretsmanager_secret" "client_key" {
  name = "eficode-access"
}

data "aws_secretsmanager_secret_version" "client_key_version" {
  secret_id = data.aws_secretsmanager_secret.client_key.id
}

#
resource "aws_key_pair" "admin_keypair" {
  key_name   = "weather-app-admin"
  public_key = data.aws_secretsmanager_secret_version.admin_key_version.secret_string

  tags = {
    Name = "app-admin-keypair"
  }
}

# network
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "weatherapp-vpc"
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-north-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "weatherapp-subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "weatherapp-igw"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "weatherapp-rt"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.rt.id
}

# Security Group
resource "aws_security_group" "ssh_http" {
  name        = "weatherapp-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
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

  tags = {
    Name = "weatherapp-sg"
  }
}

# === EC2 Instance ===
resource "aws_instance" "host" {
  ami                         = "ami-05d3e0186c058c4dd"  # Ubuntu 22.04 LTS w eu-north-1
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids      = [aws_security_group.ssh_http.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.admin_keypair.key_name

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              
              mkdir -p /home/ubuntu/.ssh
              echo "${trimspace(data.aws_secretsmanager_secret_version.admin_key_version.secret_string)}" > /home/ubuntu/.ssh/authorized_keys
              chown -R ubuntu:ubuntu /home/ubuntu/.ssh
              chmod 700 /home/ubuntu/.ssh
              chmod 600 /home/ubuntu/.ssh/authorized_keys
              
              useradd -m -s /bin/bash client
              mkdir -p /home/client/.ssh
              echo "${trimspace(data.aws_secretsmanager_secret_version.client_key_version.secret_string)}" > /home/client/.ssh/authorized_keys
              chown -R client:client /home/client/.ssh
              chmod 700 /home/client/.ssh
              chmod 600 /home/client/.ssh/authorized_keys
              usermod -aG sudo client
              
              echo "client ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/client
              
              useradd -m -s /bin/bash ansible
              mkdir -p /home/ansible/.ssh
              echo "${trimspace(data.aws_secretsmanager_secret_version.admin_key_version.secret_string)}" > /home/ansible/.ssh/authorized_keys
              chown -R ansible:ansible /home/ansible/.ssh
              chmod 700 /home/ansible/.ssh
              chmod 600 /home/ansible/.ssh/authorized_keys
              usermod -aG sudo ansible
              
              echo "ansible ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/ansible
              
              EOF

  tags = {
    Name = "weatherapp-instance"
    Environment = "development"
  }
}

# === Outputs ===
output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.host.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.host.public_dns
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = aws_subnet.main.id
}
