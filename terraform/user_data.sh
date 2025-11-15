#!/bin/bash
set -e

# Update system
echo "Updating system packages..."
sudo apt-get update -y
sudo apt-get upgrade -y

# Install Docker
echo "Installing Docker..."
sudo apt-get install -y ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add ubuntu user to docker group
sudo usermod -aG docker ubuntu

# Install Docker Compose
echo "Installing Docker Compose..."
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

docker-compose version


# Install AWS CLI v2
echo "Installing AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt-get install -y unzip
unzip awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip

# Configure AWS Region
export AWS_DEFAULT_REGION=${aws_region}

# Wait for instance profile to be available
echo "Waiting for instance profile..."
sleep 30

# Authenticate Docker with ECR
echo "Authenticating with ECR..."
aws ecr get-login-password --region ${aws_region} | sudo docker login --username AWS --password-stdin ${ecr_repo_url}
echo "Setup complete."