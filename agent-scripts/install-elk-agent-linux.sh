#!/bin/bash

# Set variables
ELASTIC_AGENT_VERSION="8.14.3"
ELASTIC_AGENT_URL="https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-${ELASTIC_AGENT_VERSION}-linux-x86_64.tar.gz"
ELASTIC_AGENT_DIR="/Elastic/elastic-agent-${ELASTIC_AGENT_VERSION}-linux-x86_64"
CERTS_DIR="${ELASTIC_AGENT_DIR}/certs"
FLEET_SERVER_URL="https://10.53.2.15:30002"
ENROLLMENT_API_KEYS_URL="http://10.53.2.15:30001/api/fleet/enrollment_api_keys"
CA_CERT_URL="https://sapfe.blob.core.windows.net/elk-files/ssh-keys/master-key.pem?sp=r&st=2024-07-27T21:03:24Z&se=2024-10-18T05:03:24Z&sv=2022-11-02&sr=b&sig=R1KjcDyRtbZcb8KerABrY0wqfUyVPXDmYHbcl9%2BPspg%3D"
MASTER_KEY_PATH="${CERTS_DIR}/master-key.pem"
CA_CERT_PATH="${CERTS_DIR}/ca.crt"
AGENT_BINARY="${ELASTIC_AGENT_DIR}/elastic-agent"

# Function to check if the command succeeded
check_command() {
    if [ $? -ne 0 ]; then
        echo "Error: $1 failed"
        exit 1
    fi
}

# Update system and install Sysmon for Linux
echo "Installing Sysmon for Linux..."
wget -q https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
check_command "Install Sysmon package"
sudo apt-get update
sudo apt-get install -y sysmonforlinux
check_command "Install Sysmon for Linux"
sudo sysmon -i
check_command "Configure Sysmon"

# Create directory for Elastic Agent and download it
echo "Setting up Elastic Agent..."
sudo mkdir -p /Elastic
cd /Elastic
sudo curl -L -O ${ELASTIC_AGENT_URL}
check_command "Download Elastic Agent"
sudo tar xzvf ${ELASTIC_AGENT_URL##*/}
check_command "Extract Elastic Agent"

# Setup certificates
echo "Setting up certificates..."
sudo mkdir -p ${CERTS_DIR}
cd ${CERTS_DIR}
sudo curl -o master-key.pem ${CA_CERT_URL}
check_command "Download master-key.pem"
sudo chmod 600 master-key.pem
check_command "Set permissions on master-key.pem"

# Download CA certificate
sudo scp -o "StrictHostKeyChecking=no" -i master-key.pem admala@10.53.2.115:/mnt/data/certs/ca/ca.crt ${CA_CERT_PATH}
sudo cp  /Elastic/elastic-agent-8.14.3-linux-x86_64/certs/ca.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
check_command "Download CA certificate"

# Get enrollment token
echo "Fetching enrollment token..."
enrollmentToken=$(curl -s -u "elastic:Aloulou556" --header 'kbn-xsrf: true' --request GET "http://10.53.2.15:30001/api/fleet/enrollment_api_keys" | grep -oP '"list":\[\{"id":"[^"]*","active":true,"api_key_id":"[^"]*","api_key":"\K[^"]+' | sed 's/","name.*//')

# Install Elastic Agent
echo "Installing Elastic Agent..."
yes | sudo ${AGENT_BINARY} install --url=${FLEET_SERVER_URL} --enrollment-token=${enrollmentToken} --certificate-authorities="/usr/local/share/ca-certificates/ca.crt"
check_command "Install Elastic Agent"

echo "Elastic Agent installation complete!"