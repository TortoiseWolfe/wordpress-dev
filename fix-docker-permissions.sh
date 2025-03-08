#!/bin/bash
# fix-docker-permissions.sh - Script to fix Docker socket permissions

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Docker Permission Fix Tool${NC}"
echo -e "${RED}WARNING: This script requires sudo privileges to modify Docker permissions${NC}"
echo "It will attempt to fix common permission issues with Docker socket."

# Prompt for confirmation
read -p "Do you want to continue? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 1
fi

# Check if user can use sudo
echo -e "\n${BLUE}Checking sudo access...${NC}"
if sudo -v; then
    echo -e "${GREEN}✓ sudo access confirmed${NC}"
else
    echo -e "${RED}✗ Cannot use sudo. This script requires sudo privileges.${NC}"
    exit 1
fi

# Stop Docker service
echo -e "\n${BLUE}Stopping Docker service...${NC}"
sudo systemctl stop docker
echo -e "${GREEN}✓ Docker service stopped${NC}"

# Fix socket permissions
echo -e "\n${BLUE}Removing Docker socket...${NC}"
if [ -e /var/run/docker.sock ]; then
    sudo rm -f /var/run/docker.sock
    echo -e "${GREEN}✓ Docker socket removed${NC}"
else
    echo -e "${YELLOW}! Docker socket not found${NC}"
fi

# Start Docker service
echo -e "\n${BLUE}Starting Docker service...${NC}"
sudo systemctl start docker
echo -e "${GREEN}✓ Docker service started${NC}"

# Verify socket permissions
echo -e "\n${BLUE}Verifying socket permissions...${NC}"
if [ -e /var/run/docker.sock ]; then
    SOCK_PERMS=$(ls -la /var/run/docker.sock)
    echo -e "Current permissions: $SOCK_PERMS"
    
    # Set permissions to 666 to allow any user to access the socket
    echo -e "\n${BLUE}Setting socket permissions to 666...${NC}"
    sudo chmod 666 /var/run/docker.sock
    
    # Verify the change
    NEW_PERMS=$(ls -la /var/run/docker.sock)
    echo -e "New permissions: $NEW_PERMS"
    echo -e "${GREEN}✓ Docker socket permissions updated${NC}"
else
    echo -e "${RED}✗ Docker socket not created after service restart${NC}"
    echo -e "This indicates a problem with Docker daemon. Check system logs."
    exit 1
fi

# Check if current user is in docker group
echo -e "\n${BLUE}Checking if user is in docker group...${NC}"
if groups | grep -q '\bdocker\b'; then
    echo -e "${GREEN}✓ User $(whoami) is in the docker group${NC}"
else
    echo -e "${YELLOW}! User $(whoami) is NOT in the docker group${NC}"
    echo -e "Adding user to docker group..."
    sudo usermod -aG docker $(whoami)
    echo -e "${GREEN}✓ User added to docker group${NC}"
    echo -e "${YELLOW}! You may need to log out and back in for this to take effect${NC}"
fi

# Verify Docker works
echo -e "\n${BLUE}Verifying Docker works...${NC}"
if docker info >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Docker is working correctly!${NC}"
else
    echo -e "${RED}✗ Docker is still not working correctly${NC}"
    echo -e "Try the following steps manually:"
    echo -e "1. Log out and log back in (to apply group changes)"
    echo -e "2. If still not working, reboot the system"
    echo -e "3. If still not working, try a full Docker reset (see README.md)"
fi

echo -e "\n${BLUE}Docker permission fix complete.${NC}"