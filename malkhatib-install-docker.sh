#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Use sudo!" 
    exit 1
fi

# Install prerequisites
echo "Installing prerequisites..."
apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker's official GPG key
echo "Adding Docker GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker's official repository
echo "Adding Docker repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker CE
echo "Installing Docker CE..."
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

# Enable and start Docker service
echo "Enabling and starting Docker service..."
systemctl enable docker
systemctl start docker

# Install Docker Compose Plugin
echo "Installing Docker Compose plugin..."
DOCKER_CONFIG=${DOCKER_CONFIG:-/usr/lib/docker/cli-plugins}
mkdir -p $DOCKER_CONFIG
curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-$(uname -m) -o $DOCKER_CONFIG/docker-compose
chmod +x $DOCKER_CONFIG/docker-compose

# Add current user to the Docker group (optional)
echo "Adding current user to Docker group..."
usermod -aG docker $SUDO_USER

# Verify installations
echo "Verifying Docker installation..."
docker --version
docker compose version

# Completion message
echo "Docker CE and Docker Compose plugin installed successfully."
echo "Please log out and back in for the user group changes to take effect."
