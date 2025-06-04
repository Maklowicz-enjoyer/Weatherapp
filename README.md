# Weatherapp

A weather application that shows current weather information using the OpenWeatherMap API.
The app is made up of three main parts:

    Frontend: React-based UI (runs on port 8000)

    Backend: Node.js API server (runs on port 9000)

    Nginx: Acts as a reverse proxy (routes traffic, runs on port 80)

All services run in Docker containers and are managed with Docker Compose.

# Prerequisites

Docker and Docker Compose installed.
OpenWeatherMap API key.

Set up environment variables
Create a .env file in the backend directory:
APPID=your_openweathermap_api_key_here
TARGET_CITY=Madrid,es
PORT=9000

Development Mode with Hot Reload
The Docker Compose setup includes volume mounts for development:
Frontend and backend source code changes are automatically reflected
No need to rebuild containers during development

Terraform Infrastructure
The project includes complete AWS infrastructure setup using Terraform:
Resources Created:

VPC: Custom network (10.0.0.0/16)
Subnet: Public subnet (10.0.1.0/24)
Internet Gateway: For external connectivity
Security Group: SSH (port 22) and HTTP (port 80) access
EC2 Instance: t3.micro Ubuntu 22.04 LTS
Key Pairs: SSH access management
Secrets Manager: Secure key storage


Deployment Commands
cd infra/terraform
terraform init
terraform plan
terraform apply

## Known Issues
lack of ansible playbooks due to unresolved ssh key issues and deadline constraints.

## Future improvments

SSL/HTTPS Implementation

Ansible Automation for:
Docker installation
Application deployment
System configuration
Security hardening
Add monitoring (Prometheus, Grafana)
CI/CD via GitHub Actions
