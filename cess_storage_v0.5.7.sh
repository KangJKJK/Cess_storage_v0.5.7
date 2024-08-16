#!/bin/bash

# Update and install required packages
echo "Updating and installing required packages..."
sudo apt update && sudo apt install -y ca-certificates curl gnupg

# Set up Docker GPG key and repository
echo "Setting up Docker repository..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update and install Docker
echo "Installing Docker..."
sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io

# Enable and start Docker service
echo "Enabling and starting Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

# Configure UFW firewall
echo "Configuring UFW firewall..."
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow 22
sudo ufw allow 4001
sudo ufw allow 4000/tcp
sudo ufw status

# Download and install CESS nodeadm
echo "Downloading and installing CESS nodeadm..."
wget https://github.com/CESSProject/cess-nodeadm/archive/v0.5.7.tar.gz
tar -xvzf v0.5.7.tar.gz
cd cess-nodeadm-0.5.7/
./install.sh

# Configure CESS profile and settings
echo "Configuring CESS profile..."
sudo cess profile testnet
sudo cess config set

echo "Script execution completed!"
