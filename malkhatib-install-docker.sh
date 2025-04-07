#!/bin/bash

# This script installs Docker Engine, Buildx plugin, and Docker Compose plugin
# according to the latest Docker documentation for Debian-based systems.

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Use sudo!"
    exit 1
fi

# Update the apt package index
echo "Updating package index..."
apt-get update

# Install prerequisites
echo "Installing prerequisites..."
apt-get install -y ca-certificates curl

# Create the keyrings directory if it doesn't exist
echo "Creating /etc/apt/keyrings directory..."
install -m 0755 -d /etc/apt/keyrings

# Add Docker's official GPG key
echo "Adding Docker's official GPG key..."
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker's apt repository
echo "Adding Docker's apt repository..."
. /etc/os-release
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $VERSION_CODENAME stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the apt package index again
echo "Updating package index after adding Docker repository..."
apt-get update

# Install Docker Engine, CLI, containerd, Buildx plugin, and Docker Compose plugin
echo "Installing Docker packages..."
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Verify the installation by running the hello-world container
echo "Verifying Docker installation by running hello-world container..."
docker run hello-world

echo "Docker Engine, Buildx plugin, and Docker Compose plugin have been installed successfully."
