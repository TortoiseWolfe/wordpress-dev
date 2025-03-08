#!/bin/bash
# check-permissions.sh - Script to diagnose and fix Docker permission issues

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Docker Permission Diagnostic Tool${NC}"
echo "This script will check for Docker permission issues and report on them."

# Check user in docker group
echo -e "\n${BLUE}Checking if user is in docker group...${NC}"
if groups | grep -q '\bdocker\b'; then
    echo -e "${GREEN}✓ User $(whoami) is in the docker group${NC}"
else
    echo -e "${RED}✗ User $(whoami) is NOT in the docker group${NC}"
    echo -e "  To fix: sudo usermod -aG docker $(whoami) && newgrp docker"
fi

# Check docker socket permissions
echo -e "\n${BLUE}Checking docker.sock permissions...${NC}"
if [ -e /var/run/docker.sock ]; then
    SOCK_PERMS=$(ls -la /var/run/docker.sock)
    SOCK_GROUP=$(stat -c '%G' /var/run/docker.sock)
    
    echo -e "docker.sock: $SOCK_PERMS"
    
    if [ "$SOCK_GROUP" = "docker" ]; then
        echo -e "${GREEN}✓ docker.sock belongs to docker group${NC}"
    else
        echo -e "${RED}✗ docker.sock belongs to $SOCK_GROUP group instead of docker${NC}"
        echo -e "  To fix: sudo chgrp docker /var/run/docker.sock"
    fi
    
    if [[ "$SOCK_PERMS" == *"srw-rw----"* ]]; then
        echo -e "${GREEN}✓ docker.sock has correct permissions${NC}"
    else
        echo -e "${RED}✗ docker.sock has incorrect permissions${NC}"
        echo -e "  To fix: sudo chmod 660 /var/run/docker.sock"
    fi
else
    echo -e "${RED}✗ docker.sock not found at /var/run/docker.sock${NC}"
    echo -e "  Is Docker daemon running? Check with: systemctl status docker"
fi

# Check Docker daemon status
echo -e "\n${BLUE}Checking Docker daemon status...${NC}"
if systemctl is-active --quiet docker; then
    echo -e "${GREEN}✓ Docker daemon is running${NC}"
else
    echo -e "${RED}✗ Docker daemon is not running${NC}"
    echo -e "  To fix: sudo systemctl start docker"
fi

# List running containers with their creation info
echo -e "\n${BLUE}Analyzing running containers...${NC}"
CONTAINERS=$(docker ps -q)
if [ -n "$CONTAINERS" ]; then
    for CONTAINER in $CONTAINERS; do
        DETAILS=$(docker inspect --format '{{.Name}} - Created: {{.Created}} - User: {{.Config.User}}' $CONTAINER)
        echo -e "$DETAILS"
    done
else
    echo -e "${YELLOW}No containers currently running${NC}"
fi

# Check for stuck containers
echo -e "\n${BLUE}Checking for potentially stuck containers...${NC}"
STUCK_CONTAINERS=$(docker ps --filter status=exited -q)
if [ -n "$STUCK_CONTAINERS" ]; then
    echo -e "${YELLOW}Found $(echo $STUCK_CONTAINERS | wc -w) exited containers that could be removed${NC}"
    echo -e "To clean up: docker rm $(echo $STUCK_CONTAINERS)"
else
    echo -e "${GREEN}No exited containers found${NC}"
fi

# Check container permissions
echo -e "\n${BLUE}Checking current user IDs...${NC}"
echo -e "User ID: $(id -u)"
echo -e "Group ID: $(id -g)"

# Check docker-compose file for user settings
echo -e "\n${BLUE}Analyzing docker-compose.yaml for user settings...${NC}"
if [ -f "docker-compose.yaml" ]; then
    USER_SETTINGS=$(grep -n "user:" docker-compose.yaml)
    if [ -n "$USER_SETTINGS" ]; then
        echo -e "${GREEN}Found user settings in docker-compose.yaml:${NC}"
        echo -e "$USER_SETTINGS"
    else
        echo -e "${YELLOW}No explicit user settings found in docker-compose.yaml${NC}"
        echo -e "Consider adding 'user: \"\${USER_ID:-1000}:\${GROUP_ID:-1000}\"' to services"
    fi
else
    echo -e "${RED}docker-compose.yaml not found${NC}"
fi

# Check environment variables for user IDs
echo -e "\n${BLUE}Checking environment variables for user IDs...${NC}"
if [ -f ".env" ]; then
    USER_ID_ENV=$(grep -E "UID=|USER_ID=" .env)
    GROUP_ID_ENV=$(grep -E "GID=|GROUP_ID=" .env)
    
    if [ -n "$USER_ID_ENV" ] || [ -n "$GROUP_ID_ENV" ]; then
        echo -e "${GREEN}Found user ID settings in .env:${NC}"
        [ -n "$USER_ID_ENV" ] && echo -e "$USER_ID_ENV"
        [ -n "$GROUP_ID_ENV" ] && echo -e "$GROUP_ID_ENV"
    else
        echo -e "${YELLOW}No user ID settings found in .env${NC}"
        echo -e "Consider adding:"
        echo -e "USER_ID=$(id -u)"
        echo -e "GROUP_ID=$(id -g)"
    fi
else
    echo -e "${YELLOW}.env file not found${NC}"
fi

echo -e "\n${BLUE}Docker permission check complete.${NC}"
echo -e "If you're experiencing permission issues, consider:"
echo -e "1. Stopping Docker: sudo systemctl stop docker"
echo -e "2. Fixing permissions as suggested above"
echo -e "3. Restarting Docker: sudo systemctl start docker"
echo -e "4. If all else fails, rebooting the system"