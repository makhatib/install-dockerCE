#!/bin/bash

# This script installs Docker Engine, Buildx plugin, and Docker Compose plugin
# by automatically detecting if the host is running Debian, Ubuntu, or a Debian-like derivative.
# It then configures the correct repository and installs Docker accordingly.

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Use sudo!"
    exit 1
fi

# Load OS release information
if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    echo "Cannot determine the operating system (missing /etc/os-release)."
    exit 1
fi

# Determine OS-specific settings
if [[ "$ID" == "ubuntu" ]]; then
    OS_KEY_URL="https://download.docker.com/linux/ubuntu/gpg"
    OS_REPO_URL="https://download.docker.com/linux/ubuntu"
    OS_CODENAME=$(lsb_release -cs)
    KEY_FILE="/etc/apt/keyrings/docker.gpg"
elif [[ "$ID" == "debian" ]]; then
    OS_KEY_URL="https://download.docker.com/linux/debian/gpg"
    OS_REPO_URL="https://download.docker.com/linux/debian"
    OS_CODENAME="$VERSION_CODENAME"
    KEY_FILE="/etc/apt/keyrings/docker.asc"
elif [[ "$ID_LIKE" == *"debian"* ]]; then
    # For derivatives of Debian (if not strictly Ubuntu)
    OS_KEY_URL="https://download.docker.com/linux/debian/gpg"
    OS_REPO_URL="https://download.docker.com/linux/debian"
    OS_CODENAME="$VERSION_CODENAME"
    KEY_FILE="/etc/apt/keyrings/docker.asc"
else
    echo "Unsupported OS: $ID. This script supports Debian-based systems only."
    exit 1
fi

echo "Detected OS: $ID, version codename: $OS_CODENAME"

# Update the apt package index
echo "Updating package index..."
apt-get update

# Install prerequisites: ca-certificates, curl, gnupg, and lsb-release
echo "Installing prerequisites..."
apt-get install -y ca-certificates curl gnupg lsb-release

# Create the keyrings directory if it doesn't exist
echo "Ensuring /etc/apt/keyrings directory exists..."
install -m 0755 -d /etc/apt/keyrings

# Add Docker's official GPG key from the correct URL
echo "Adding Docker's official GPG key from $OS_KEY_URL..."
curl -fsSL "$OS_KEY_URL" -o "$KEY_FILE"
chmod a+r "$KEY_FILE"

# Add Docker's apt repository for the target OS
echo "Adding Docker's apt repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=$KEY_FILE] $OS_REPO_URL $OS_CODENAME stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the package index after adding the Docker repository
echo "Updating package index after adding Docker repository..."
apt-get update

# Install Docker Engine, CLI, containerd, Buildx plugin, and Docker Compose plugin
echo "Installing Docker packages..."
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Verify the installation by running the hello-world container
echo "Verifying Docker installation by running the hello-world container..."
docker run hello-world

echo "Docker Engine, Buildx plugin, and Docker Compose plugin have been installed successfully."
